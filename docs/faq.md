# Frequently Asked Questions

Common questions about StarLoco Docker.

## General

### What is StarLoco Docker?

StarLoco Docker is a one-command Dofus Retro private server stack. It includes login, game, database, cache, and web portal in automated Docker containers.

### What does "one-command deployment" mean?

Run `./run.sh start` and everything starts — no manual setup, no complex configuration, no external downloads at runtime.

### Who is this for?

- Beginners who want to try hosting a Dofus server
- Hobbyists who want to tweak rates and settings
- Power users who want to test custom forks

### Is this beginner-safe?

Yes. Defaults are tuned to work out of the box. Just run the start command.

## Setup

### How do I get started?

```bash
git clone https://github.com/tiboitel/starloco-docker.git
cd starloco-docker
./run.sh start
```

See [Quick Start](quick-start.md).

### What do I need before starting?

- Docker 20.10+
- Docker Compose
- Ports 80, 450, 5555, 3306, 6379 available

### How do I change my server IP?

Edit `GAME_SERVER_IP` in `.env`:

```bash
GAME_SERVER_IP=192.168.1.100
```

Then restart:

```bash
./run.sh restart
```

### What does each service do?

| Service | Purpose |
|---------|---------|
| login | Handles player login and account creation |
| game | Runs the game world |
| mariadb | Stores accounts and game data |
| redis | Caches sessions and transient data |
| web | Serves the portal and downloads |

### What ports are used?

- Login: 450, 666
- Game: 5555, 666
- MariaDB: 3306
- Redis: 6379
- Web: 80

### Can I run this on a VPS?

Yes. Use a VPS with at least 4 GB RAM and 4 vCPU. Set `BIND_ADDRESS=0.0.0.0` in `.env`.

## Game Settings

### How do I change the server name?

Edit `GAME_SERVER_NAME` in `.env`:

```bash
GAME_SERVER_NAME=MyDofusServer
```

### How do I change rates?

Edit rate variables in `.env`:

```bash
RATE_XP=3
RATE_DROP=5
RATE_KAMAS=10
```

### How do I add admins?

This requires direct database access. Not exposed through `.env`. Manual setup required.

## Fork Support

### Can I use my own fork?

Yes, experimental fork support allows custom repository, ref, and JAR overrides.

See [Fork Support Guide](fork-support.md).

### Are forks supported?

Fork support is experimental. No guarantee. Test locally first.

## Data and Backups

### How do I back up my server?

```bash
./run.sh backup
```

See [Backup and Restore Guide](backup-restore.md).

### How do I restore a backup?

```bash
./run.sh restore
```

**Warning:** This overwrites all existing data.

### Where are backups stored?

In the `backups/` directory.

## Troubleshooting

### Services won't start

1. Check logs: `./run.sh logs -f`
2. Restart: `./run.sh stop && ./run.sh start`
3. If it persists, see [Troubleshooting Guide](troubleshooting.md)

### Client can't connect

1. Verify `BIND_ADDRESS=0.0.0.0` in `.env`
2. Check firewall has ports 450 and 5555 open
3. Verify `GAME_SERVER_IP` is your public IP

### Forgot my server key

Check `.env` — `GAME_SERVER_KEY` is stored there in plain text.

### Need more help?

- [Quick Start](quick-start.md)
- [Troubleshooting](troubleshooting.md)
- [Backup and Restore](backup-restore.md)
- [Fork Support](fork-support.md)