# StarLoco Docker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-20.10+-2496ED?style=flat&logo=docker)](https://www.docker.com/)
[![Stars](https://img.shields.io/github/stars/tiboitel/starloco-docker)](https://github.com/tiboitel/starloco-docker)
[![Last commit](https://img.shields.io/github/last-commit/tiboitel/starloco-docker)](https://github.com/tiboitel/starloco-docker)

One-command Dofus Retro server with Docker. Community sandbox for beginners, hobbyists, and fork users.

## About This Project

StarLoco Docker is a reproducible Dofus Retro server stack for local hosting, VPS deployment, and fork experimentation. It packages login, game, database, cache, and web services into one Docker-based workflow with safe defaults and no runtime downloads.

**Why use this instead of manual setup:**
- No manual server assembly
- No runtime downloads from external sources
- Secrets are auto-generated
- Defaults are tuned for beginners
- Optional fork overrides for advanced users

## Quick Start

```bash
./run.sh start
```

First run generates secrets automatically, builds Docker images, and starts all services.

**Ports exposed:**
- Login: `localhost:450`
- Game: `localhost:5555`
- Web: `localhost:80`
- Redis: `localhost:6379`
- Zaap: `localhost:8000`

See [Quick Start Guide](docs/quick-start.md) for full details.

## Usage

### One-Command Start
Run `./run.sh start` to generate secrets, build images, and start the full stack.

### Local Hosting
Use the default `.env` values for a beginner-friendly local setup, then connect a Dofus 1.39.8 client.

### Server Customization
Edit `.env` to change server IP, name, rates, and other gameplay settings without modifying code.

### Fork Experimentation
Use the experimental fork overrides to point the build at compatible custom repositories, refs, and JAR files. See [Fork Support](docs/fork-support.md).

## What's Included

| Service | Purpose | Ports |
|---------|---------|-------|
| login | Authentication server | 450, 666 |
| game | World server | 5555, 666 |
| mariadb | Account and game database | 3306 |
| redis | Session and cache | 6379 |
| web | Portal and downloads | 80 |
| zaap | Auth API for legacy clients | 8000 |

Additional features:
- Backup and restore
- Production mode with resource limits
- Health checks for all services
- JSON-structured logs
- Experimental fork support

## Configuration

### Secrets

On first launch, `./run.sh` creates secrets in `secrets/` if missing:
- `mariadb_root.secret` — MariaDB root password
- `starloco_db_password.secret` — Game database password
- `exchange_key.secret` — Server exchange key

`./run.sh clean` removes all containers, volumes, and local secrets to support secret rotation.

**Important:** Copy the `secrets/` folder to any other hosts before starting there.

### Environment Variables

Edit `.env` for basic settings:

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
| `RATE_KAMAS` | `1` | Kamas multiplier |

See the included `.env.example` for all options.

## Commands

| Command | Description |
|---------|-------------|
| `./run.sh start` | Start all services (default) |
| `./run.sh start --prod` | Start with production config |
| `./run.sh start --build` | Rebuild Docker images |
| `./run.sh stop` | Stop all services |
| `./run.sh restart` | Restart all services |
| `./run.sh logs -f` | View logs |
| `./run.sh logs [service]` | View specific service logs |
| `./run.sh status` | Show service status |
| `./run.sh backup` | Backup data |
| `./run.sh restore` | Restore from backup |
| `./run.sh clean` | Delete all data |

## Production Mode

Production mode includes resource limits, health checks, log rotation, auto-restart, and non-root containers:

```bash
./run.sh start --prod
```

| Service | Memory | CPU |
|---------|--------|-----|
| mariadb | 1.5 GB | 1.0 |
| redis | 256 MB | 0.25 |
| login | 768 MB | 0.5 |
| game | 2 GB | 2.0 |
| web | 384 MB | 0.25 |
| zaap | 256 MB | 0.25 |

## Backup & Restore

See [Backup and Restore Guide](docs/backup-restore.md).

```bash
./run.sh backup
./run.sh restore
```

**Warning:** Restore overwrites all existing data.

## Troubleshooting

See [Troubleshooting Guide](docs/troubleshooting.md).

Common issues:
- Services won't start — check logs with `./run.sh logs -f`
- Connection refused — verify firewall/port forwarding and `BIND_ADDRESS`
- Build fails — force rebuild with `./run.sh start --build`

## Experimental Fork Support

StarLoco Docker supports optional fork overrides. This is experimental and compatibility is not guaranteed.

You can override:
- Game repository URL
- Game ref (tag/branch/commit)
- Game JAR filename
- Login repository URL
- Login ref
- Login JAR filename
- Zaap repository URL
- Zaap ref

Add to `.env`:

```bash
STARLOCO_GAME_REPO=https://github.com/myuser/StarLoco-Game.git
STARLOCO_GAME_REF=my-custom-branch
STARLOCO_LOGIN_REPO=https://github.com/myuser/StarLoco-Login.git
STARLOCO_LOGIN_REF=v1.0.2
ZAAP_REPO=https://github.com/myuser/zaap.git
ZAAP_REF=my-custom-branch
```

Then rebuild:

```bash
./run.sh start --build
```

For a fork to work, it must:
- Use the same database schema as StarLoco
- Follow the same configuration format
- Expose the same ports
- Include Lua scripts in the repository

See [Fork Support Guide](docs/fork-support.md) for full details.

## FAQ

See [FAQ](docs/faq.md).

- **Can I use my own fork?** — Yes, via experimental fork overrides.
- **Is this beginner-safe?** — Yes, defaults work out of the box with one command.
- **How do I change my server IP?** — Edit `GAME_SERVER_IP` in `.env`.
- **What should I edit first?** — Start with `GAME_SERVER_KEY` and `GAME_SERVER_NAME`.

## License

MIT License — Modify and distribute as you wish.
