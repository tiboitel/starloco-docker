#!/bin/sh
set -eu

if [ -f "${MYSQL_PASSWORD_FILE:-}" ]; then
  export MYSQL_PASSWORD="$(tr -d '\r\n' < "${MYSQL_PASSWORD_FILE}")"
fi

exec uvicorn app.main:app --host "${API_HOST:-0.0.0.0}" --port "${API_PORT:-8000}"