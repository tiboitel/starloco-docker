#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="$SCRIPT_DIR/../secrets"

mkdir -p "$SECRETS_DIR"

echo "Generating TLS certificates for StarLoco..."

openssl genrsa -out "$SECRETS_DIR/mariadb_ca_key.secret" 4096 2>/dev/null

openssl req -new -x509 -days 3650 -key "$SECRETS_DIR/mariadb_ca_key.secret" \
    -out "$SECRETS_DIR/mariadb_ca.secret" \
    -subj "/CN=StarLoco CA/O=StarLoco/C=FR" 2>/dev/null

openssl genrsa -out "$SECRETS_DIR/mariadb_server_key.secret" 2048 2>/dev/null

openssl req -new -key "$SECRETS_DIR/mariadb_server_key.secret" \
    -out /tmp/mariadb_server.csr \
    -subj "/CN=mariadb/O=StarLoco/C=FR" 2>/dev/null

openssl x509 -req -days 365 -in /tmp/mariadb_server.csr \
    -CA "$SECRETS_DIR/mariadb_ca.secret" \
    -CAkey "$SECRETS_DIR/mariadb_ca_key.secret" \
    -CAcreateserial \
    -out "$SECRETS_DIR/mariadb_server.secret" \
    -extfile <(printf "subjectAltName=DNS:mariadb,DNS:localhost,IP:127.0.0.1") 2>/dev/null

rm -f /tmp/mariadb_server.csr "$SECRETS_DIR/mariadb_ca_key.secret"

openssl rand -hex 32 > "$SECRETS_DIR/truststore_password.secret"

chmod 600 "$SECRETS_DIR"/*.secret

echo "Certificates generated successfully!"
echo ""
echo "Files created in $SECRETS_DIR:"
ls -la "$SECRETS_DIR"/*.secret
echo ""
echo "NOTE: Add these to .gitignore if not already present"