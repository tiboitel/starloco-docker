#!/bin/bash

JAR_URL="https://github.com/StarLoco/StarLoco-Game/releases/download/v1.0.6/game.jar"
JAR_FILE="/app/game.jar"
CONFIG_FILE="/app/config/game.config.properties"

mkdir -p /app/data /app/Logs/Error /app/Logs/General /app/config /app/scripts /app/scripts/data /app/scripts/models
SCRIPT_DIR="/app/scripts"

if [ ! -f "$JAR_FILE" ]; then
    echo "Downloading StarLoco Game Server..."
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

# Generate config from environment variables and secrets
generate_config() {
    cat > "$CONFIG_FILE" << EOF
# StarLoco - Game Server Configuration
# Generated from environment variables and secrets

system.server.exchange.ip login
system.server.exchange.port 666
system.server.exchange.bind 0.0.0.0
system.server.exchange.key ${EXCHANGE_KEY}
system.server.encyption false
system.server.debug true
system.server.logs true

database.login.host mariadb
database.login.port 3306
database.login.user ${STARLOCO_DB_USER:-starloco}
database.login.pass ${STARLOCO_DB_PASSWORD}
database.login.name starloco_login

database.game.host mariadb
database.game.port 3306
database.game.user ${STARLOCO_DB_USER:-starloco}
database.game.pass ${STARLOCO_DB_PASSWORD}
database.game.name starloco_game

system.server.game.ip ${GAME_SERVER_IP:-127.0.0.1}
system.server.game.port 5555
system.server.game.id ${GAME_SERVER_ID:-601}
system.server.game.key ${GAME_SERVER_KEY:-starloco}
system.server.game.version ${GAME_SERVER_VERSION:-1.39.8}
system.server.game.rate.xp ${RATE_XP:-1}
system.server.game.rate.drop ${RATE_DROP:-1}
system.server.game.rate.dropThreshold ${RATE_DROP_THRESHOLD:-1}
system.server.game.rate.honor ${RATE_HONOR:-1}
system.server.game.rate.kamas ${RATE_KAMAS:-1}
system.server.game.rate.job ${RATE_JOB:-1}
system.server.game.rate.fm ${RATE_FM:-1}
system.server.game.start.message Welcome to StarLoco !
system.server.game.start.level 1
system.server.game.start.kamas 0
system.server.game.start.map -1
system.server.game.start.cell -1
system.server.game.limitByIp 8
system.server.game.subscription false
system.server.game.autoReboot false
system.server.game.resetLimit true
system.server.game.maxPets false
system.server.game.allZaap false
system.server.game.allEmotes false
system.server.game.allowMulePvp false
system.server.game.timeByTurn 30
system.server.game.mode.christmas false
system.server.game.mode.halloween false
system.server.game.mode.heroic false
system.server.game.mode.event false
system.server.game.timeBetweenEvent 60
EOF
    echo "Config generated from secrets and environment variables"
}

# Always regenerate config
generate_config

if [ ! -f "${SCRIPT_DIR}/Common.lua" ] || [ ! -f "/tmp/scripts_downloaded" ]; then
    echo "Downloading all Lua scripts and maps from GitHub (this may take a while)..."
    rm -rf /tmp/starloco-git
    if git clone --depth 1 https://github.com/StarLoco/StarLoco-Game.git /tmp/starloco-git 2>&1; then
        cp -r /tmp/starloco-git/scripts/* "${SCRIPT_DIR}/"
        rm -rf /tmp/starloco-git
        echo "Scripts downloaded successfully"
    else
        echo "Warning: Could not download scripts from GitHub"
    fi
    touch /tmp/scripts_downloaded
fi

echo "Starting StarLoco Game Server..."
echo "Rates: XP=${RATE_XP:-1} JOB=${RATE_JOB:-1} FM=${RATE_FM:-1} KAMAS=${RATE_KAMAS:-1}"
cd /app
exec java $JAVA_OPTS -jar "$JAR_FILE"
