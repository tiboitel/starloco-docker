# StarLoco Docker - Architecture

## Overview

- **Project**: Dofus 1.39.8 retro private server - Docker deployment
- **Stack**: Docker Compose, Java 21 (eclipse-temurin), MariaDB 11.3, Redis 7, PHP
- **Purpose**: Easy-to-deploy, near industry-grade deployment for StarLoco server
- **License**: MIT

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        starloco network                         │
│                                                                  │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐     │
│  │  Login  │───▶│  Game   │◀───│ MariaDB │    │  Redis  │     │
│  │ :450    │    │ :5555   │    │ :3306   │    │ :6379   │     │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘     │
│       │               │               │               │        │
│       └───────────────┴───────────────┴───────────────┘        │
│                           │                                      │
│                    ┌──────┴──────┐                               │
│                    │     Web     │                               │
│                    │    :80      │                               │
│                    └─────────────┘                               │
└─────────────────────────────────────────────────────────────────┘
```

## Services

| Service | Image/Build | Port | Purpose |
|---------|-------------|------|---------|
| **login** | `./login/Dockerfile` | 450 | Authentication server (Java 21) |
| **game** | `./game/Dockerfile` | 5555 | Game server (Java 21) |
| **web** | `./web/Dockerfile` | 80 | Web interface (PHP-FPM + Nginx) |
| **mariadb** | mariadb:11.3 | 3306 | Game database |
| **redis** | redis:7-alpine | 6379 | Caching and session storage |

## Data Flow

```
Client (Dofus 1.39.8)
    │
    ├─▶ :450 (Login Server) ──▶ MariaDB (auth)
    │                              │
    │                              ▼
    └─▶ :5555 (Game Server) ──▶ MariaDB (game data)
    │                    │
    │                    └─▶ Redis (caching, sessions)
    │
    └─▶ :80 (Web Interface) ──▶ PHP + MariaDB
```

## Project Structure

```
.
├── .env                 # Environment variables
├── .env.example          # Environment template
├── .gitignore           # Git ignore rules
├── README.md            # Project documentation
├── run.sh               # Main management script
├── docker-compose.yml   # Development compose config
├── docker-compose.prod.yml  # Production compose config
│
├── db-init/             # Database initialization scripts
│   ├── 00-init.sql      # Core database initialization
│   ├── 01-*.sql         # Login database updates
│   ├── 04-game.sql      # Game database schema
│   └── 11-*.sql         # Post-init fixes
│
├── login/               # Login server (Java 21)
│   ├── Dockerfile
│   └── entrypoint.sh
│
├── game/                # Game server (Java 21)
│   ├── Dockerfile
│   └── entrypoint.sh
│
├── web/                 # Web interface (PHP)
│   ├── Dockerfile
│   └── nginx.conf
│
├── secrets/             # Sensitive configuration (gitignored)
│   ├── mariadb_root.secret
│   ├── starloco_db_password.secret
│   └── exchange_key.secret
│
└── backups/            # Database backups (auto-created)
```

## Configuration

### Secrets (Required)

| File | Description | Required For |
|------|-------------|--------------|
| `secrets/mariadb_root.secret` | MariaDB root password | Database initialization |
| `secrets/starloco_db_password.secret` | Game DB user password | Login/Game servers |
| `secrets/exchange_key.secret` | Server exchange key | Authentication |

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BIND_ADDRESS` | `0.0.0.0` | Listen address |
| `GAME_SERVER_IP` | `127.0.0.1` | Public IP for clients |
| `GAME_SERVER_ID` | `601` | Server identifier |
| `GAME_SERVER_KEY` | `shogun` | Server authentication key |
| `GAME_SERVER_VERSION` | `1.39.8` | Dofus client version |
| `RATE_XP` | `1` | Experience multiplier |
| `RATE_DROP` | `1` | Drop rate multiplier |
| `RATE_KAMAS` | `1` | Currency multiplier |
| `RATE_JOB` | `1` | Job skill multiplier |
| `GAME_SERVER_DEBUG` | `false` | Debug mode toggle |

## Commands

```bash
./run.sh start              # Start all services
./run.sh start --prod       # Start with production config
./run.sh start --build      # Start with image rebuild
./run.sh stop               # Stop all services
./run.sh restart            # Restart all services
./run.sh logs               # View all logs
./run.sh status             # Show service status
./run.sh backup            # Backup to backups/
./run.sh restore           # Restore from backup
./run.sh clean             # Delete all data
```

## Security Features

- **Non-root users**: Containers run as non-root (UID 1000 - `starloco` user)
- **Secrets management**: Docker secrets for sensitive data
- **Network isolation**: Single bridge network (`starloco`)
- **Health checks**: All services monitored
- **Production mode**: Resource limits, restart policies, log rotation

## Known Issues

### TLS for MariaDB (Not Yet Supported)

TLS encryption for MariaDB is not yet implemented due to a known upstream issue in the MariaDB Docker image.

**Error**: `SSL_CTX_set_default_verify_paths failed`

**Status**: Investigated multiple solutions:
- ❌ Custom Dockerfile with ca-certificates
- ❌ Different MariaDB versions (10.11, 11.3, 11.4)
- ❌ Volume mounts vs Docker secrets
- ❌ Config file approach

**Root Cause**: MariaDB's SSL initialization attempts to load default system paths, which fails in the Docker environment even when ca-certificates are installed.

**Reference**: [MariaDB/docker#592](https://github.com/MariaDB/mariadb-docker/issues/592)

**Workaround**: Database connections remain unencrypted within the Docker network. For production, consider:
1. Using a separate MariaDB host with proper TLS
2. Waiting for upstream fix
3. Using a different database (PostgreSQL with official TLS support)

## External Dependencies

- **Login Server JAR**: https://github.com/StarLoco/StarLoco-Login/releases
- **Game Server JAR**: https://github.com/StarLoco/StarLoco-Game/releases
- **Lua Scripts**: Downloaded from StarLoco-Game repository at runtime

## Constraints

- **Single maintainer** - Keep changes simple and documented
- **Production-ready** - Use production compose for deployments
- **No breaking changes** - Database migrations must be backward compatible