#!/bin/bash

JAR_FILE="/app/login.jar"
CONFIG_FILE="/app/login.config.properties"

mkdir -p /app/data

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

    echo "Ensuring world server metadata in database..."
    SAFE_GAME_SERVER_KEY=${GAME_SERVER_KEY:-starloco}
    SAFE_GAME_SERVER_KEY=${SAFE_GAME_SERVER_KEY//\'/\'\'}
    SAFE_GAME_SERVER_NAME=${GAME_SERVER_NAME:-StarLoco}
    SAFE_GAME_SERVER_NAME=${SAFE_GAME_SERVER_NAME//\'/\'\'}

    UPDATE_OK=false
    for attempt in 1 2 3; do
        if mariadb --skip-ssl -h "${MARIADB_HOST:-mariadb}" \
            -u "${STARLOCO_DB_USER:-starloco}" \
            -p"${STARLOCO_DB_PASSWORD}" \
            starloco_login \
            -e "UPDATE world_servers SET \`key\`='${SAFE_GAME_SERVER_KEY}', name='${SAFE_GAME_SERVER_NAME}' WHERE id=${GAME_SERVER_ID:-601};"; then
            UPDATE_OK=true
            echo "World server metadata updated (attempt $attempt)"
            break
        else
            echo "Warning: Update failed (attempt $attempt/3), retrying..."
            sleep 2
        fi
    done

    if [ "$UPDATE_OK" != "true" ]; then
        echo "ERROR: Failed to update world server metadata after 3 attempts"
        return 1
    fi

    VERIFY_KEY=$(mariadb --skip-ssl -h "${MARIADB_HOST:-mariadb}" \
        -u "${STARLOCO_DB_USER:-starloco}" \
        -p"${STARLOCO_DB_PASSWORD}" \
        starloco_login \
        -sN -e "SELECT \`key\` FROM world_servers WHERE id=${GAME_SERVER_ID:-601};")

    if [ "${VERIFY_KEY}" = "${SAFE_GAME_SERVER_KEY}" ]; then
        echo "World server key verified: ${VERIFY_KEY}"
    else
        echo "ERROR: World server key mismatch - expected '${SAFE_GAME_SERVER_KEY}', got '${VERIFY_KEY}'"
        return 1
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
system.server.zaap.enabled=true

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
update_world_server || { echo "ERROR: Failed to update world server, exiting"; exit 1; }

echo "Starting StarLoco Login Server..."
cd /app
exec java $JAVA_OPTS -jar "$JAR_FILE"
