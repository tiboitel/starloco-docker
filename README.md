# StarLoco Docker

Dofus Retro private server - one command deployment.

## Prerequisites

- Docker & Docker Compose
- Secrets files in `secrets/`

## Quick Start

```bash
./run.sh start
```

Server available at:
- Login: `localhost:450`
- Game: `localhost:5555`
- Web: `localhost:80`
- Redis: `localhost:6379`

## Configuration

### Secrets

Edit files in `secrets/`:

| File | Description |
|------|-------------|
| `mariadb_root.secret` | Database root password |
| `starloco_db_password.secret` | Game database user password |
| `exchange_key.secret` | Server exchange key |

Default values are provided for testing. Change them for production.

### Environment

Edit `.env` for custom settings (optional):

```bash
BIND_ADDRESS=0.0.0.0
GAME_SERVER_IP=127.0.0.1
GAME_SERVER_ID=601
GAME_SERVER_KEY=shogun
GAME_SERVER_VERSION=1.39.8
RATE_XP=1
RATE_DROP=1
RATE_KAMAS=1
```

## Commands

| Command | Description |
|---------|-------------|
| `./run.sh start` | Start all services |
| `./run.sh start --prod` | Start with production config |
| `./run.sh stop` | Stop services |
| `./run.sh restart` | Restart services |
| `./run.sh logs` | View logs |
| `./run.sh logs [service]` | View specific service logs |
| `./run.sh status` | Show status |
| `./run.sh backup` | Backup data to `backups/` |
| `./run.sh restore` | Restore from backup |
| `./run.sh clean` | Delete all data |

## Production Mode

Production mode includes:
- Resource limits (CPU/memory)
- Health checks
- Log rotation
- Restart policies

```bash
./run.sh start --prod
```

## Troubleshooting

### Services won't start
```bash
./run.sh logs
```

### Database connection errors
Check secrets files are correctly formatted (no trailing newlines).

### Reset everything
```bash
./run.sh clean
```

## Backup & Restore

### Backup
```bash
./run.sh backup
```
Creates `backups/backup-YYYYMMDD-HHMMSS.tar.gz`

### Restore
```bash
./run.sh restore
```
Lists available backups and restores selected one.

## License

MIT License - Modify and distribute as you wish.
