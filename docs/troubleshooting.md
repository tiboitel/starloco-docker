# Troubleshooting Guide

Common issues and how to fix them.

## Services Won't Start

### Symptoms
Services fail to start, or some services stay in a `starting` or `restarting` state.

### How to Fix
1. Check the logs:
```bash
./run.sh logs -f
```

2. Look for error messages in the output. Common causes:
   - Port already in use — stop another service on that port
   - Missing secrets — delete the `secrets/` folder and restart to regenerate
   - Database error — check MariaDB logs with `./run.sh logs mariadb`

3. Restart all services:
```bash
./run.sh stop
./run.sh start
```

## Client Connection Refused

### Symptoms
The Dofus client cannot connect to the login or game server. Error such as "Connexion impossible" or "Connection refused".

### How to Fix
1. Check that services are running:
```bash
./run.sh status
```

2. Verify ports are accessible:
- Login: port 450
- Game: port 5555

3. If hosting online:
   - Set `BIND_ADDRESS=0.0.0.0` in `.env`
   - Set `GAME_SERVER_IP` to your public IP
   - Open ports 450, 5555, 80 in your firewall

4. Restart after editing `.env`:
```bash
./run.sh restart
```

## Docker Build Fails

### Symptoms
Image build fails during `./run.sh start --build` or `./run.sh start`.

### How to Fix
1. Force a rebuild:
```bash
./run.sh start --build
```

2. Check Docker is running:
```bash
docker info
```

3. Clear Docker cache if disk space is low:
```bash
docker system prune -a
```

## Logs Show Strange Output

### How to View Logs
```bash
./run.sh logs -f           # all services
./run.sh logs game        # game server only
./run.sh logs login      # login server only
./run.sh logs mariadb    # database only
./run.sh logs redis     # cache only
./run.sh logs web       # web portal only
```

## Reset Everything

### Warning
This deletes all data including accounts and game progress.

```bash
./run.sh clean
./run.sh start
```

## Secrets Won't Generate

### Symptoms
Error about missing secrets or permission denied.

### How to Fix
1. Delete the `secrets/` folder:
```bash
rm -rf secrets/
```

2. Restart — `./run.sh start` regenerates secrets automatically.

3. If permissions persist, check the directory is writable:
```bash
chmod 755 secrets/
```

## Need More Help

- Check the [FAQ](faq.md)
- Check [Backup and Restore](backup-restore.md)
- Open an issue on GitHub if the problem persists