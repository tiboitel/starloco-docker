# Quick Start — Run a Dofus Retro Server with Docker

Get a working Dofus Retro server running in about 5 minutes.

## Prerequisites

- Docker 20.10+
- Docker Compose
- Ports 80, 450, 5555, 3306, 6379 available

## Step 1: Clone the Repository

```bash
git clone https://github.com/tiboitel/starloco-docker.git
cd starloco-docker
```

## Step 2: Configure Basic Settings

Create or edit `.env`:

```bash
cp .env.example .env
```

At minimum, set your server identity:

```bash
GAME_SERVER_KEY=YourSecretKey
GAME_SERVER_NAME=YourServerName
GAME_SERVER_IP=127.0.0.1  # Use your public IP if hosting online
```

## Step 3: Start the Server

```bash
./run.sh start
```

First run:
- Generates secrets automatically
- Builds Docker images (may take a few minutes)
- Starts all five services

## Step 4: Connect

A Dofus 1.39.8 client is required. Tested with 1.39.8 — newer clients untested. Connect to the server:

- Login server: `localhost:450` (or your public IP on port 450)
- Game server: `localhost:5555` (or your public IP on port 5555)

## Expected Output

```
[+] Starting starloco-docker
[+] Generated secrets
[+] Building Docker images
[+] Starting services
[+] Login server ready on port 450
[+] Game server ready on port 5555
[+] Web portal ready on port 80
```

## Verify Services Are Running

```bash
./run.sh status
```

All services should show as `healthy` or `running`.

## Edit Your Server

Common first edits in `.env`:

| Variable | Purpose |
|----------|---------|
| `GAME_SERVER_KEY` | Server password |
| `GAME_SERVER_NAME` | Server display name |
| `GAME_SERVER_IP` | Public IP players connect to |
| `RATE_XP` | Experience rate (default 1) |
| `RATE_DROP` | Drop rate (default 1) |

Restart to apply changes:

```bash
./run.sh restart
```

## Stop the Server

```bash
./run.sh stop
```

## Next Steps

- [Backup and Restore](backup-restore.md) — protect your data
- [Troubleshooting](troubleshooting.md) — common fixes
- [Fork Support](fork-support.md) — use custom forks
- [FAQ](faq.md) — common questions
