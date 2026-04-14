#!/bin/bash
set -euo pipefail

# Ensure the required databases exist and the configured DB user has privileges.
# This script runs inside the official MariaDB docker-entrypoint-initdb.d context
# during first initialization. It prefers Docker secrets at /run/secrets/* and
# falls back to environment variables.

read_secret() {
  # Usage: read_secret ENV_NAME SECRET_FILENAME
  local envname="$1"
  local filename="$2"
  local val=""
  if [ -f "/run/secrets/$filename" ]; then
    # Trim CR/LF
    val="$(tr -d '\r' < "/run/secrets/$filename" | tr -d '\n')"
  else
    # fallback to environment variable if present
    val="${!envname:-}"
  fi
  printf '%s' "$val"
}

# Required runtime variables (try secrets first, then env vars)
MARIADB_ROOT_PASSWORD="$(read_secret MARIADB_ROOT_PASSWORD mariadb_root_secret)"
DB_USER="${MARIADB_USER:-${STARLOCO_DB_USER:-starloco}}"
# MariaDB server's user password — the password used by the 'starloco' user.
MARIADB_PASSWORD="$(read_secret MARIADB_PASSWORD starloco_db_password_secret)"

if [ -z "$MARIADB_ROOT_PASSWORD" ]; then
  echo "ERROR: MARIADB_ROOT_PASSWORD not provided (secret or env). Aborting."
  exit 1
fi

if [ -z "$MARIADB_PASSWORD" ]; then
  echo "ERROR: starloco/starloco DB password not provided (secret or env). Aborting."
  exit 1
fi

mysql_args=(mysql -uroot -p"$MARIADB_ROOT_PASSWORD" -h127.0.0.1 -P3306)

cat <<SQL | "${mysql_args[@]}"
-- Create the required databases if they do not exist
CREATE DATABASE IF NOT EXISTS starloco_login CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS starloco_game CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Ensure the DB user can access both DBs. IDENTIFIED BY here ensures the password is set
-- if the user was created by the image, and also works if the user already exists.
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON starloco_login.* TO '${DB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON starloco_game.* TO '${DB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
FLUSH PRIVILEGES;
SQL

echo "00-create-required-dbs.sh: done"
