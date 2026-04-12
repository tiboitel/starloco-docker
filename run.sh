#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_DIR="$SCRIPT_DIR"

cd "$COMPOSE_DIR"

# Load environment variables (non-sensitive only)
if [ -f ".env" ]; then
    set -a
    source .env
    set +a
fi

# Read secrets for script operations
read_secrets() {
    if [ -f "secrets/mariadb_root.secret" ]; then
        export MARIADB_ROOT_PASSWORD=$(cat secrets/mariadb_root.secret)
    fi
    if [ -f "secrets/starloco_db_password.secret" ]; then
        export STARLOCO_DB_PASSWORD=$(cat secrets/starloco_db_password.secret)
    fi
}

read_secrets

COMPOSE_CMD=""

check_dependencies() {
    echo "Checking dependencies..."
    
    if ! command -v docker &> /dev/null; then
        echo "ERROR: Docker is not installed."
        exit 1
    fi
    
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        echo "ERROR: Docker Compose is not installed."
        exit 1
    fi
    
    echo "  Docker: $(docker --version)"
    echo "  Docker Compose: $COMPOSE_CMD"
}

download_sql() {
    echo "Downloading SQL databases..."
    
    mkdir -p mariadb-init
    
    REQUIRED_FILES=(
        "02-login.sql"
        "04-game.sql"
        "05-update_game_16.04.23.sql"
        "06-update_game_23.04.23.sql"
        "07-update_game_24.04.23.sql"
        "08-update_game_08.05.23.sql"
        "09-update_game_10.03.2024.sql"
    )
    
    all_exist=true
    for file in "${REQUIRED_FILES[@]}"; do
        if [ ! -f "mariadb-init/$file" ]; then
            all_exist=false
            break
        fi
    done
    
    if [ "$all_exist" = true ]; then
        echo "  SQL files already exist, skipping download."
        return
    fi
    
    if ! command -v curl &> /dev/null; then
        echo "  curl not found. Please download SQL files manually."
        return
    fi
    
    BASE_URL="https://raw.githubusercontent.com/StarLoco/StarLoco/main/docker/db-init"
    
    echo "Downloading 02-login.sql..."
    curl -L -o mariadb-init/02-login.sql "${BASE_URL}/02-login.sql" 2>/dev/null || echo "  Failed"
    
    echo "Downloading 04-game.sql..."
    curl -L -o mariadb-init/04-game.sql "${BASE_URL}/04-game.sql" 2>/dev/null || echo "  Failed"
    
    echo "Downloading 05-update_game_16.04.23.sql..."
    curl -L -o mariadb-init/05-update_game_16.04.23.sql "${BASE_URL}/05-update_game_16.04.23.sql" 2>/dev/null || echo "  Failed"
    
    echo "Downloading 06-update_game_23.04.23.sql..."
    curl -L -o mariadb-init/06-update_game_23.04.23.sql "${BASE_URL}/06-update_game_23.04.23.sql" 2>/dev/null || echo "  Failed"
    
    echo "Downloading 07-update_game_24.04.23.sql..."
    curl -L -o mariadb-init/07-update_game_24.04.23.sql "${BASE_URL}/07-update_game_24.04.23.sql" 2>/dev/null || echo "  Failed"
    
    echo "Downloading 08-update_game_08.05.23.sql..."
    curl -L -o mariadb-init/08-update_game_08.05.23.sql "${BASE_URL}/08-update_game_08.05.23.sql" 2>/dev/null || echo "  Failed"
    
    echo "Downloading 09-update_game_10.03.2024.sql..."
    curl -L -o mariadb-init/09-update_game_10.03.2024.sql "${BASE_URL}/09-update_game_10.03.2024.sql" 2>/dev/null || echo "  Failed"
    
    echo "  SQL download complete!"
}

import_sql_databases() {
    echo "Importing SQL databases..."
    
    DB_USER="${STARLOCO_DB_USER:-starloco}"
    DB_PASSWORD="${STARLOCO_DB_PASSWORD}"
    ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD}"
    
    if [ -f "mariadb-init/02-login.sql" ]; then
        echo "  Importing 02-login.sql to starloco_login..."
        mysql -h127.0.0.1 -uroot -p"$ROOT_PASSWORD" starloco_login < mariadb-init/02-login.sql 2>/dev/null || \
            echo "  WARNING: Could not import 02-login.sql"
    fi
    
    if [ -f "mariadb-init/04-game.sql" ]; then
        echo "  Importing 04-game.sql to starloco_game..."
        mysql -h127.0.0.1 -uroot -p"$ROOT_PASSWORD" starloco_game < mariadb-init/04-game.sql 2>/dev/null || \
            echo "  WARNING: Could not import 04-game.sql"
    fi
    
    echo "  Applying game patches..."
    PATCHES=(
        "05-update_game_16.04.23.sql"
        "06-update_game_23.04.23.sql"
        "07-update_game_24.04.23.sql"
        "08-update_game_08.05.23.sql"
        "09-update_game_10.03.2024.sql"
    )
    
    for patch in "${PATCHES[@]}"; do
        if [ -f "mariadb-init/$patch" ]; then
            echo "    Applying $patch..."
            mysql -h127.0.0.1 -uroot -p"$ROOT_PASSWORD" starloco_game < mariadb-init/$patch 2>/dev/null || \
                echo "    WARNING: Could not apply $patch"
        fi
    done
    
    echo "  SQL databases imported!"
}

import_sql_database 

start_services() {
    echo "Starting services..."
    $COMPOSE_CMD up -d --build
    
    echo ""
    echo "Waiting for services to start..."
    sleep 5
    
    echo ""
    $COMPOSE_CMD ps
}

show_logs() {
    echo ""
    echo "=========================================="
    echo " Starloco Server Started!"
    echo "=========================================="
    echo ""
    echo " Services:"
    echo "   - Login Server:    localhost:450"
    echo "   - Game Server:     localhost:5555"
    echo "   - Redis:           localhost:6379"
    echo ""
    echo " To view logs: ./run.sh logs"
    echo " To stop:      ./run.sh stop"
    echo ""
}

show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start       Start all services (default)"
    echo "  stop        Stop all services"
    echo "  restart     Restart all services"
    echo "  logs        Show logs"
    echo "  status      Show service status"
    echo "  clean       Stop and remove all containers and volumes"
    echo "  help        Show this help message"
}

case "${1:-start}" in
    start)
        check_dependencies
        download_sql
        start_services
        show_logs
        ;;
    stop)
        check_dependencies
        echo "Stopping services..."
        $COMPOSE_CMD down --remove-orphans
        echo "Services stopped."
        ;;
    restart)
        check_dependencies
        echo "Restarting services..."
        $COMPOSE_CMD down --remove-orphans
        $COMPOSE_CMD up -d --build
        $COMPOSE_CMD ps
        ;;
    logs)
        check_dependencies
        $COMPOSE_CMD logs -f --tail=100 "${2:-}"
        ;;
    status)
        check_dependencies
        $COMPOSE_CMD ps -a
        ;;
    clean)
        check_dependencies
        echo "WARNING: This will delete all data!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            $COMPOSE_CMD down -v --remove-orphans
            echo "All data deleted."
        fi
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
