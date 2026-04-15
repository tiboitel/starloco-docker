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
| `mariadb_root.secret` | MariaDB root password for maintenance/admin tasks |
| `starloco_db_password.secret` | Game database user password |
| `exchange_key.secret` | Server exchange key |

Default values are provided for testing. Change them for production.

**Note:** Secrets files must not have trailing newlines. To check:
```bash
cat -A secrets/mariadb_root.secret
```
If you see `$` at the end of the line, remove it with:
```bash
sed -i 's/\r$//' secrets/*.secret
```

### Environment

Edit `.env` for custom settings:

| Variable | Default | Description |
|----------|---------|-------------|
| `BIND_ADDRESS` | `0.0.0.0` | Listen address (use `127.0.0.1` for localhost only) |
| `GAME_SERVER_IP` | `127.0.0.1` | Public IP players connect to |
| `GAME_SERVER_ID` | `601` | Server identifier |
| `GAME_SERVER_KEY` | `YOUR_GAME_SERVER_KEY` | Server authentication key |
| `GAME_SERVER_NAME` | `YOUR_GAME_SERVER_NAME` | Server display name |
| `GAME_SERVER_VERSION` | `1.39.8` | Dofus client version |
| `RATE_XP` | `1` | Experience multiplier |
| `RATE_DROP` | `1` | Drop rate multiplier |
| `RATE_DROP_THRESHOLD` | `1` | Drop threshold multiplier |
| `RATE_KAMAS` | `1` | Kamas (currency) multiplier |
| `RATE_JOB` | `1` | Job skill multiplier |
| `RATE_FM` | `1` | Smithmagic (crafting) multiplier |
| `RATE_HONOR` | `1` | Honor/PvP multiplier |
| `GAME_SERVER_DEBUG` | `false` | Enable debug mode for troubleshooting |

## Commands

| Command | Description |
|---------|-------------|
| `./run.sh start` | Start all services (default) |
| `./run.sh start --prod` | Start with production config |
| `./run.sh start --build` | Start with image rebuild |
| `./run.sh stop` | Stop all services |
| `./run.sh restart` | Restart all services |
| `./run.sh restart --prod` | Restart with production config |
| `./run.sh logs -f` | View all logs |
| `./run.sh logs [service]` | View specific service logs |
| `./run.sh status` | Show service status |
| `./run.sh backup` | Backup data to `backups/` |
| `./run.sh restore` | Restore from backup |
| `./run.sh clean` | Delete all data |
| `./run.sh help` | Show help |

## Production Mode

Production mode includes:

| Feature | Description |
|---------|-------------|
| Resource limits | CPU and memory limits per service |
| Health checks | Service health monitoring |
| Log rotation | Logs limited to 10MB per file, 3 files max |
| Restart policies | Auto-restart on failure |
| Non-root users | Containers run as non-root (UID 1000) |

**Note:** TLS for MariaDB is not yet supported (known upstream issue).

`GAME_SERVER_KEY` and `GAME_SERVER_NAME` are synced into `world_servers` on game startup, so `.env` is the only file you need to edit for server identity changes.

```bash
./run.sh start --prod
```

### Resource Limits (Production)

| Service | Memory | CPU |
|---------|--------|-----|
| mariadb | 512MB | 1.0 |
| redis | 256MB | 0.5 |
| login | 512MB | 1.0 |
| game | 1024MB | 2.0 |
| web | 128MB | 0.5 |

## Troubleshooting

### Services won't start

```bash
./run.sh logs -f
```

### Database connection errors

Check secrets files are correctly formatted (no trailing newlines):
```bash
sed -i 's/\r$//' secrets/*.secret
```

### Client connection refused

1. Check firewall/port forwarding
2. Verify `BIND_ADDRESS` in `.env` (use `0.0.0.0` for LAN/internet)
3. Ensure services are running: `./run.sh status`

### Images fail to build

Force rebuild with the `--build` flag:
```bash
./run.sh start --build
```

### View specific service logs

```bash
./run.sh logs game
./run.sh logs login
./run.sh logs mariadb
./run.sh logs redis
./run.sh logs web
```

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

**Tip:** Backups include MariaDB and Redis data volumes.

### Restore

```bash
./run.sh restore
```

Lists available backups and restores selected one.

**Warning:** Restore will stop all services and overwrite existing data.

## License

MIT License - Modify and distribute as you wish.
