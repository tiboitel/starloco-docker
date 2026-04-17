# StarLoco Docker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-20.10+-2496ED?style=flat&logo=docker)](https://www.docker.com/)
[![Stars](https://img.shields.io/github/stars/tiboitel/starloco-docker)](https://github.com/tiboitel/starloco-docker)
[![Last commit](https://img.shields.io/github/last-commit/tiboitel/starloco-docker)](https://github.com/tiboitel/starloco-docker)

Dofus Retro private server - one command deployment.

## Prerequisites

- Docker & Docker Compose

## Quick Start

```bash
./run.sh start
```

Secrets are auto-generated on first launch if missing.

Server available at:
- Login: `localhost:450`
- Game: `localhost:5555`
- Web: `localhost:80`
- Redis: `localhost:6379`

## Configuration

### Secrets

On first launch, `./run.sh` auto-generates secrets in `secrets/` if missing:

| File | Description |
|------|-------------|
| `mariadb_root.secret` | MariaDB root password (maintenance) |
| `starloco_db_password.secret` | Game database user password |
| `exchange_key.secret` | Server exchange key |

**Important:** Copy `secrets/` to other hosts before starting there.

**Regenerate:** Delete a secret file and restart to generate a new one.

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
The game service also waits for the login service to become healthy before starting its own exchange connection.

```bash
./run.sh start --prod
```

### Resource Limits (Production)

| Service | Memory | CPU |
|---------|--------|------|
| mariadb | 1.5 GB | 1.0 |
| redis | 256 MB | 0.25 |
| login | 768 MB | 0.5 |
| game | 2 GB | 2.0 |
| web | 384 MB | 0.25 |

Tuned for **performance + stability** on 8 GB RAM / 4 vCPU entry-mid VPS or laptop.
For smaller instances, adjust values down proportionally.

## Troubleshooting

### Services won't start

```bash
./run.sh logs -f
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

## External Dependencies

| Artifact | Source | Integrity |
|----------|--------|------------|
| Game server JAR | GitHub releases (StarLoco-Game) | Baked at build time (v1.0.6) |
| Login server JAR | GitHub releases (StarLoco-Login) | Baked at build time (v1.0.1) |
| Lua scripts | StarLoco-Game scripts/ | Baked at build time (v1.0.6) |

**Note:** All artifacts are fetched at build time and baked into the images. No runtime downloads.

## License

MIT License - Modify and distribute as you wish.
