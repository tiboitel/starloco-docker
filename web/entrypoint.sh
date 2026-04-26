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
chown -R www-data:www-data "$RUNTIME_ROOT"

if [ -n "$DB_PASSWORD" ]; then
    CONFIG_FILE="$CONFIG_FILE" DB_PASSWORD="$DB_PASSWORD" php << 'PHPSCRIPT'
<?php
$file = getenv('CONFIG_FILE');
$password = getenv('DB_PASSWORD');
$content = file_get_contents($file);
$content = str_replace("define('LOGIN_DB_PASS', 'starloco_password');", "define('LOGIN_DB_PASS', '" . $password . "');", $content);
$content = str_replace("define('JIVA_DB_PASS', 'starloco_password');", "define('JIVA_DB_PASS', '" . $password . "');", $content);
$content = str_replace("define('DB_PASS', 'starloco_password');", "define('DB_PASS', '" . $password . "');", $content);
file_put_contents($file, $content);
PHPSCRIPT
fi

# Fix server IPs (for checkState) and DB IPs (for newPdo connections)
# The original config uses 127.0.0.1 for everything - we need proper Docker service names
CONFIG_FILE="$CONFIG_FILE" php << 'PHPSCRIPT'
<?php
$file = getenv('CONFIG_FILE');
$content = file_get_contents($file);
$content = str_replace("define('LOGIN_IP', '127.0.0.1');", "define('LOGIN_IP', 'login');", $content);
$content = str_replace("define('JIVA_IP', '127.0.0.1');", "define('JIVA_IP', 'game');", $content);
$content = str_replace("define('DB_IP', '127.0.0.1');", "define('DB_IP', 'mariadb');", $content);
file_put_contents($file, $content);
PHPSCRIPT

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
