#!/bin/bash

JAR_URL="https://github.com/StarLoco/StarLoco-Login/releases/download/v1.0.1/login.jar"
JAR_FILE="/app/login.jar"
CONFIG_FILE="/app/login.config.properties"

mkdir -p /app/data

if [ ! -f "$JAR_FILE" ]; then
    echo "Downloading StarLoco Login Server..."
    curl -L -o "$JAR_FILE" "$JAR_URL"
fi

# Read secrets from Docker secrets or environment
read_secrets() {
    if [ -f "/run/secrets/starloco_db_password_secret" ]; then
        STARLOCO_DB_PASSWORD=$(tr -d '\r\n' < /run/secrets/starloco_db_password_secret)
    fi
    
    if [ -f "/run/secrets/exchange_key_secret" ]; then
        EXCHANGE_KEY=$(tr -d '\r\n' < /run/secrets/exchange_key_secret)
    fi
    
    if [ -f "/run/secrets/mariadb_root_secret" ]; then
        MARIADB_ROOT_PASSWORD=$(tr -d '\r\n' < /run/secrets/mariadb_root_secret)
    fi
    
    if [ -f "/run/secrets/truststore_password_secret" ]; then
        TRUSTSTORE_PASSWORD=$(tr -d '\r\n' < /run/secrets/truststore_password_secret)
    fi
}

read_secrets

# Generate TLS truststore if CA cert exists
generate_truststore() {
    if [ -f "/run/secrets/mariadb_ca_secret" ] && [ -n "$TRUSTSTORE_PASSWORD" ]; then
        if [ ! -f "/app/truststore.jks" ]; then
            echo "Generating Java truststore for TLS..."
            keytool -import -alias mariadb -file /run/secrets/mariadb_ca_secret \
                -keystore /app/truststore.jks -storepass "$TRUSTSTORE_PASSWORD" \
                -noprompt 2>/dev/null
            echo "Truststore generated"
        fi
    fi
}

generate_truststore

# Add TLS truststore to Java options if available
if [ -f "/app/truststore.jks" ] && [ -n "$TRUSTSTORE_PASSWORD" ]; then
    export JAVA_OPTS="$JAVA_OPTS -Djavax.net.ssl.trustStore=/app/truststore.jks -Djavax.net.ssl.trustStorePassword=$TRUSTSTORE_PASSWORD"
fi

# Generate config from environment variables and secrets
generate_config() {
    cat > "$CONFIG_FILE" << EOF
# StarLoco - Login Server Configuration
# Generated from environment variables and secrets

system.server.exchange.ip 0.0.0.0
system.server.exchange.port 666
system.server.exchange.key ${EXCHANGE_KEY}

system.server.login.ip 0.0.0.0
system.server.login.port 450
system.server.login.version ${GAME_SERVER_VERSION:-1.39.8}

database.login.host ${MARIADB_HOST:-mariadb}
database.login.port 3306
database.login.user ${STARLOCO_DB_USER:-starloco}
database.login.pass ${STARLOCO_DB_PASSWORD}
database.login.name starloco_login

system.server.game.ip ${GAME_SERVER_IP:-127.0.0.1}
system.server.game.port 5555
system.server.game.id ${GAME_SERVER_ID:-601}
system.server.game.key ${GAME_SERVER_KEY:-starloco}
system.server.game.version ${GAME_SERVER_VERSION:-1.39.8}
EOF
    echo "Config generated from secrets and environment variables"
}

# Always regenerate config
generate_config

echo "Starting StarLoco Login Server..."
cd /app
exec java $JAVA_OPTS -jar "$JAR_FILE"
