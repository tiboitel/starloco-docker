#!/bin/sh
set -e

SOURCE_ROOT="/src/public"
RUNTIME_ROOT="/runtime/public"
CONFIG_FILE="$RUNTIME_ROOT/configuration/configuration.php"

if [ -f "/run/secrets/starloco_db_password_secret" ]; then
    DB_PASSWORD=$(tr -d '\r\n' < /run/secrets/starloco_db_password_secret)
else
    DB_PASSWORD=${STARLOCO_DB_PASSWORD:-}
fi

rm -rf "$RUNTIME_ROOT"
cp -R "$SOURCE_ROOT" "$RUNTIME_ROOT"

if [ -n "$DB_PASSWORD" ]; then
    sed -i "s/define('LOGIN_DB_PASS', 'starloco_password');/define('LOGIN_DB_PASS', '$(printf %s "$DB_PASSWORD" | sed "s/'/'\\''/g")');/" "$CONFIG_FILE"
    sed -i "s/define('JIVA_DB_PASS', 'starloco_password');/define('JIVA_DB_PASS', '$(printf %s "$DB_PASSWORD" | sed "s/'/'\\''/g")');/" "$CONFIG_FILE"
    sed -i "s/define('DB_PASS', 'starloco_password');/define('DB_PASS', '$(printf %s "$DB_PASSWORD" | sed "s/'/'\\''/g")');/" "$CONFIG_FILE"
fi

# Fix server IPs (for checkState) and DB IPs (for newPdo connections)
# The original config uses 127.0.0.1 for everything - we need proper Docker service names
sed -i "s/define('LOGIN_IP', '127.0.0.1');/define('LOGIN_IP', 'login');/" "$CONFIG_FILE"
sed -i "s/define('JIVA_IP', '127.0.0.1');/define('JIVA_IP', 'game');/" "$CONFIG_FILE"
sed -i "s/define('DB_IP', '127.0.0.1');/define('DB_IP', 'mariadb');/" "$CONFIG_FILE"

# Fix newPdo function to map login/game to mariadb for DB connections
# Use PHP to do proper string replacement (the original config incorrectly uses login/game for DB)
CONFIG_FILE="$CONFIG_FILE" php << 'PHPSCRIPT'
<?php
$file = getenv("CONFIG_FILE") ?: "/runtime/public/configuration/configuration.php";
$content = file_get_contents($file);
$search = 'function newPdo($ip, $user, $pass, $db) {';
$replace = 'function newPdo($ip, $user, $pass, $db) {
    // Fix: map login/game to mariadb for MySQL connections
    if ($ip === "login" || $ip === "game") $ip = "mariadb";';
$content = str_replace($search, $replace, $content);
file_put_contents($file, $content);
PHPSCRIPT

exec sh -c "php-fpm83 & nginx -g 'daemon off;'"
