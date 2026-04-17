# Backup and Restore Guide

How to protect your server data using built-in backup and restore commands.

## Backup

Create a backup of all data:

```bash
./run.sh backup
```

This creates a timestamped archive in `backups/`:
```
backups/backup-YYYYMMDD-HHMMSS.tar.gz
```

### What's Included in a Backup

- MariaDB data (accounts, game state, characters)
- Redis data (sessions, cache)
- All service configurations

### Backup Retention

- Backups are stored in the `backups/` directory
- Each backup is a full snapshot
- Manually clean old backups to save disk space

## Restore

Restore from a previous backup:

```bash
./run.sh restore
```

This lists available backups and prompts you to select one.

**Warning:** Restore stops all services and overwrites all existing data. This cannot be undone.

### Restore Process

1. Stop all services
2. Extract the selected backup archive
3. Restart all services
4. Verify with `./run.sh status`

## Restore Best Practices

- Test restores periodically — don't wait for a disaster
- Keep backups in a safe location (off-server, if possible)
- Back up before making any major changes
- Back up before upgrading

## Scheduled Backups (Optional)

Set up automated backups using cron or task scheduler:

```bash
# Example: daily backup at 3am
0 3 * * * cd /path/to/starloco-docker && ./run.sh backup
```

Or use a simple script that runs `./run.sh backup` on a schedule.

## Manual Backup (Optional)

If you need more control, backup manually:

```bash
# Backup MariaDB
docker exec mariadb mysqldump -u root -p"$(cat secrets/mariadb_root.secret)" starloco_login > backup.sql

# Backup Redis
docker exec redis redis-cli SAVE
docker cp redis:/data/dump.rdb ./backup-dump.rdb
```

Restore these manually with `docker exec` and `mysql` commands.

## Related Pages

- [Quick Start](quick-start.md) — get started
- [Troubleshooting](troubleshooting.md) — fix issues