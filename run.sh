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
PROD_MODE=false

# Parse arguments for --prod flag
while [[ $# -gt 0 ]]; do
    case $1 in
        --prod)
            PROD_MODE=true
            COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.prod.yml"
            shift
            ;;
        --dev)
            PROD_MODE=false
            shift
            ;;
        *)
            shift
            ;;
    esac
done

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

start_services() {
    echo "Starting services..."
    $COMPOSE_CMD $COMPOSE_FILES up -d --build
    
    echo ""
    echo "Waiting for services to start..."
    sleep 5
    
    echo ""
    $COMPOSE_CMD -f docker-compose.yml ps
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
    echo "Usage: $0 [command] [--prod|--dev]"
    echo ""
    echo "Commands:"
    echo "  start       Start all services (default)"
    echo "  start --prod    Start services with production config"
    echo "  stop        Stop all services"
    echo "  restart     Restart all services"
    echo "  logs        Show logs"
    echo "  status      Show service status"
    echo "  clean       Stop and remove all containers and volumes"
    echo "  help        Show this help message"
    echo ""
    echo "Options:"
    echo "  --prod      Use production compose file"
    echo "  --dev       Use development compose file (default)"
}

case "${1:-start}" in
    start)
        check_dependencies
        start_services
        show_logs
        ;;
    stop)
        check_dependencies
        echo "Stopping services..."
        $COMPOSE_CMD $COMPOSE_FILES down --remove-orphans
        echo "Services stopped."
        ;;
    restart)
        check_dependencies
        echo "Restarting services..."
        $COMPOSE_CMD $COMPOSE_FILES down --remove-orphans
        $COMPOSE_CMD $COMPOSE_FILES up -d --build
        $COMPOSE_CMD -f docker-compose.yml ps
        ;;
    logs)
        check_dependencies
        $COMPOSE_CMD $COMPOSE_FILES logs -f --tail=100 "${2:-}"
        ;;
    status)
        check_dependencies
        $COMPOSE_CMD -f docker-compose.yml ps -a
        ;;
    clean)
        check_dependencies
        echo "WARNING: This will delete all data!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            $COMPOSE_CMD -f docker-compose.yml down -v --remove-orphans
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
