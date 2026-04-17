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
    
}

read_secrets

update_world_server() {
    if [ -z "${STARLOCO_DB_PASSWORD:-}" ] || [ -z "${GAME_SERVER_NAME:-}" ]; then
        echo "Warning: Skipping world server update because required values are missing"
        return 0
    fi

    echo "Updating world server metadata from environment variables..."
    SAFE_GAME_SERVER_KEY=${GAME_SERVER_KEY:-starloco}
    SAFE_GAME_SERVER_KEY=${SAFE_GAME_SERVER_KEY//\'/\'\'}
    SAFE_GAME_SERVER_NAME=${GAME_SERVER_NAME:-StarLoco}
    SAFE_GAME_SERVER_NAME=${SAFE_GAME_SERVER_NAME//\'/\'\'}
    SAFE_DB_PASSWORD=$(echo "${STARLOCO_DB_PASSWORD}" | sed "s/'/\\\\'/g")

    if mariadb --skip-ssl -h "${MARIADB_HOST:-mariadb}" \
        -u "${STARLOCO_DB_USER:-starloco}" \
        -p"${SAFE_DB_PASSWORD}" \
        starloco_login \
        -e "UPDATE world_servers SET \`key\`='${SAFE_GAME_SERVER_KEY}', name='${SAFE_GAME_SERVER_NAME}' WHERE id=${GAME_SERVER_ID:-601};"; then
        echo "World server metadata updated successfully"
    else
        echo "Warning: Failed to update world server metadata ( continuing anyway)"
    fi
}

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
update_world_server

echo "Starting StarLoco Login Server..."
cd /app
exec java $JAVA_OPTS -jar "$JAR_FILE"
