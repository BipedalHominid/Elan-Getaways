# Web Server Daily Backup System

Automated backup solution for the `~/webservers/` directory to an external hard drive (Toshiba UAS Controller).

## Quick Start

### 1. Initial Setup

```bash
# Navigate to the directory containing the scripts
cd /home/user/Elan-Getaways

# Make the setup script executable
chmod +x setup-daily-backup.sh

# Run the setup (this configures the daily cron job)
./setup-daily-backup.sh
```

### 2. Manual Backup (Test Run)

Before relying on automated backups, test the system manually:

```bash
# Make sure your external hard drive is connected
# Then run the backup script
./backup-server.sh
```

### 3. Monitor Backups

```bash
# View the backup log
tail -f backup.log

# View the cron execution log
tail -f backup-cron.log

# List all backups on the external drive
ls -lh /mnt/backup-drive/webservers-backups/
```

## Configuration

Edit `backup-server.sh` to customize:

- **SOURCE_DIR**: Directory to back up (default: `~/webservers`)
- **MOUNT_POINT**: Where to mount the external drive (default: `/mnt/backup-drive`)
- **RETENTION_DAYS**: How long to keep old backups (default: 30 days)
- **CRON_TIME**: When to run backups (default: 2:00 AM daily)

## Backup Schedule

By default, backups run daily at 2:00 AM. To change the schedule:

```bash
crontab -e
```

Common cron schedule examples:
- `0 2 * * *` - Daily at 2:00 AM (current)
- `0 */6 * * *` - Every 6 hours
- `0 0 * * 0` - Weekly on Sunday at midnight
- `0 3 * * 1-5` - Weekdays at 3:00 AM

## What Gets Backed Up

The script backs up everything in `~/webservers/` except:
- `.git` directories
- `node_modules` directories
- `*.log` files
- The backup scripts themselves

## How It Works

1. **Detection**: Checks for the Toshiba external hard drive
2. **Mounting**: Automatically mounts the drive to `/mnt/backup-drive`
3. **Backup**: Uses rsync to efficiently copy files
4. **Versioning**: Each backup is timestamped (e.g., `webservers-backup-2025-12-27_14-30-00`)
5. **Cleanup**: Automatically removes backups older than 30 days
6. **Logging**: All operations are logged to `backup.log`

## Restoring from Backup

To restore files from a backup:

```bash
# List available backups
ls -lh /mnt/backup-drive/webservers-backups/

# View the latest backup
ls -lh /mnt/backup-drive/webservers-backups/latest/

# Restore a specific file
cp /mnt/backup-drive/webservers-backups/latest/path/to/file ~/webservers/path/to/file

# Restore entire directory
rsync -av /mnt/backup-drive/webservers-backups/latest/ ~/webservers/
```

## Troubleshooting

### External Drive Not Detected

```bash
# Check if the drive is connected
lsusb | grep "0480:a006"

# Check available block devices
ls -la /dev/sd*

# Manually specify the device in backup-server.sh
```

### Permission Issues

```bash
# Make sure you have sudo access
sudo -v

# Fix ownership of backup directory
sudo chown -R $USER:$USER /mnt/backup-drive/webservers-backups/
```

### Disk Space Issues

```bash
# Check available space on external drive
df -h /mnt/backup-drive

# Manually clean up old backups
rm -rf /mnt/backup-drive/webservers-backups/webservers-backup-2025-01-*
```

## Files Included

- `backup-server.sh` - Main backup script
- `setup-daily-backup.sh` - One-time setup script for cron
- `backup.log` - Backup operation log
- `backup-cron.log` - Cron execution log
- `BACKUP-README.md` - This file

## Security Notes

- Backups are stored unencrypted on the external drive
- Make sure to physically secure the external hard drive
- Consider encrypting sensitive data before backing up
- Keep the external drive disconnected when not in use for added security

## Support

For issues or questions, check the logs:
```bash
tail -50 backup.log
tail -50 backup-cron.log
```
