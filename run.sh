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
        export MARIADB_ROOT_PASSWORD=$(tr -d '\r\n' < secrets/mariadb_root.secret)
    fi
    if [ -f "secrets/starloco_db_password.secret" ]; then
        export STARLOCO_DB_PASSWORD=$(tr -d '\r\n' < secrets/starloco_db_password.secret)
    fi
}

read_secrets

COMPOSE_CMD=""
COMPOSE_FILES="-f docker-compose.yml"

# Parse command first
CMD="${1:-start}"

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

parse_flags() {
    # Parse remaining arguments for --prod/--dev flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            --prod)
                COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.prod.yml"
                shift
                ;;
            --dev)
                COMPOSE_FILES="-f docker-compose.yml"
                shift
                ;;
            --build)
                BUILD_FLAG="--build"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

start_services() {
    echo "Starting services..."
    $COMPOSE_CMD $COMPOSE_FILES up -d ${BUILD_FLAG:-}
    
    echo ""
    echo "Waiting for services to start..."
    sleep 5
    
    echo ""
    $COMPOSE_CMD $COMPOSE_FILES ps
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
    echo "Usage: $0 [command] [--prod|--dev] [--build]"
    echo ""
    echo "Commands:"
    echo "  start       Start all services (default)"
    echo "  start --prod    Start services with production config"
    echo "  stop        Stop all services"
    echo "  restart     Restart all services"
    echo "  logs        Show logs"
    echo "  logs [service]  Show specific service logs"
    echo "  status      Show service status"
    echo "  backup      Backup data to backups/"
    echo "  restore     Restore data from backup"
    echo "  clean       Stop and remove all containers and volumes"
    echo "  help        Show this help message"
    echo ""
    echo "Options:"
    echo "  --prod      Use production compose file"
    echo "  --dev       Use development compose file (default)"
    echo "  --build     Force image rebuild (start/restart)"
}

backup_data() {
    check_dependencies
    mkdir -p backups
    
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    BACKUP_FILE="backups/backup-${TIMESTAMP}.tar.gz"
    
    echo "Creating backup: $BACKUP_FILE"
    
    $COMPOSE_CMD $COMPOSE_FILES down
    
    docker run --rm \
        -v starloco-docker_mariadb_data:/data/mariadb \
        -v starloco-docker_redis_data:/data/redis \
        -v "$PWD/backups":/backup \
        alpine tar czf "/backup/backup-${TIMESTAMP}.tar.gz" -C /data .
    
    $COMPOSE_CMD $COMPOSE_FILES up -d
    
    echo "Backup created: $BACKUP_FILE"
}

restore_data() {
    check_dependencies
    
    if [ ! -d "backups" ] || [ -z "$(ls -A backups/*.tar.gz 2>/dev/null)" ]; then
        echo "No backups found in backups/ directory."
        exit 1
    fi
    
    echo "Available backups:"
    ls -lh backups/*.tar.gz
    
    echo ""
    read -p "Enter backup filename to restore: " BACKUP_FILE
    
    if [ ! -f "backups/$BACKUP_FILE" ]; then
        echo "Backup file not found: $BACKUP_FILE"
        exit 1
    fi
    
    echo "WARNING: This will STOP services and OVERWRITE all data!"
    read -p "Are you sure? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        echo "Restore cancelled."
        exit 0
    fi
    
    echo "Stopping services..."
    $COMPOSE_CMD $COMPOSE_FILES down
    
    echo "Restoring from: $BACKUP_FILE"
    docker run --rm \
        -v starloco-docker_mariadb_data:/data/mariadb \
        -v starloco-docker_redis_data:/data/redis \
        -v "$PWD/backups":/backup \
        alpine tar xzf "/backup/$BACKUP_FILE" -C /data
    
    echo "Starting services..."
    $COMPOSE_CMD $COMPOSE_FILES up -d
    
    echo "Restore complete."
}

case "$CMD" in
    start)
        shift
        parse_flags "$@"
        check_dependencies
        start_services
        show_logs
        ;;
    stop)
        shift
        parse_flags "$@"
        check_dependencies
        echo "Stopping services..."
        $COMPOSE_CMD $COMPOSE_FILES down --remove-orphans
        echo "Services stopped."
        ;;
    restart)
        shift
        parse_flags "$@"
        check_dependencies
        echo "Restarting services..."
        $COMPOSE_CMD $COMPOSE_FILES down --remove-orphans
        $COMPOSE_CMD $COMPOSE_FILES up -d ${BUILD_FLAG:-}
        $COMPOSE_CMD $COMPOSE_FILES ps
        ;;
    logs)
        shift
        SERVICE="${1:-}"
        check_dependencies
        $COMPOSE_CMD $COMPOSE_FILES logs -f --tail=100 "$SERVICE"
        ;;
    status)
        shift
        parse_flags "$@"
        check_dependencies
        $COMPOSE_CMD $COMPOSE_FILES ps -a
        ;;
    clean)
        shift
        parse_flags "$@"
        check_dependencies
        echo "WARNING: This will delete all data!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            $COMPOSE_CMD $COMPOSE_FILES down -v --remove-orphans
            echo "All data deleted."
        fi
        ;;
    backup)
        shift
        parse_flags "$@"
        backup_data
        ;;
    restore)
        shift
        parse_flags "$@"
        restore_data
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $CMD"
        show_help
        exit 1
        ;;
esac
