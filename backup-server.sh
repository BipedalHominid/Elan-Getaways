#!/bin/bash

###############################################################################
# Web Server Daily Backup Script
# Backs up the Elan Getaways web server directory to external hard drive
###############################################################################

# Configuration
SOURCE_DIR="$HOME/webservers"
EXTERNAL_DRIVE_UUID="0480a006"  # Toshiba UAS Controller device ID
MOUNT_POINT="/mnt/backup-drive"
BACKUP_DIR="$MOUNT_POINT/webservers-backups"
LOG_FILE="/home/user/Elan-Getaways/backup.log"
RETENTION_DAYS=30  # Keep backups for 30 days
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_NAME="webservers-backup-$DATE"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to send notification (optional)
notify() {
    # You can add email notifications here if needed
    log "NOTIFICATION: $1"
}

# Start backup process
log "========================================="
log "Starting backup process"
log "========================================="

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log "ERROR: Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Find the external drive device
DEVICE=$(lsusb | grep "0480:a006" | head -n 1)
if [ -z "$DEVICE" ]; then
    log "ERROR: External hard drive not detected (Toshiba UAS Controller)"
    log "Please connect the external hard drive and try again"
    exit 1
fi

log "External hard drive detected: $DEVICE"

# Find the actual block device
BLOCK_DEVICE=$(find /dev -name "sd*" -o -name "nvme*" 2>/dev/null | head -n 1)
if [ -z "$BLOCK_DEVICE" ]; then
    # Try alternative method to find the device
    BLOCK_DEVICE=$(ls /dev/sd* 2>/dev/null | grep -E "sd[a-z][0-9]?" | tail -n 1)
fi

if [ -z "$BLOCK_DEVICE" ]; then
    log "WARNING: Could not automatically detect block device"
    log "Please specify the device manually (e.g., /dev/sdb1)"
    log "Available devices:"
    ls -la /dev/sd* /dev/nvme* 2>/dev/null | grep -E "^b" | tee -a "$LOG_FILE"
    exit 1
fi

log "Using block device: $BLOCK_DEVICE"

# Create mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    log "Creating mount point: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
fi

# Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    log "External drive already mounted at $MOUNT_POINT"
else
    # Mount the external drive
    log "Mounting external drive..."
    sudo mount "$BLOCK_DEVICE" "$MOUNT_POINT" 2>&1 | tee -a "$LOG_FILE"

    if [ $? -ne 0 ]; then
        log "ERROR: Failed to mount external drive"
        exit 1
    fi

    log "Successfully mounted external drive"
fi

# Create backup directory if it doesn't exist
if [ ! -d "$BACKUP_DIR" ]; then
    log "Creating backup directory: $BACKUP_DIR"
    sudo mkdir -p "$BACKUP_DIR"
    sudo chown -R $USER:$USER "$BACKUP_DIR"
fi

# Create the backup
log "Creating backup: $BACKUP_NAME"
log "Source: $SOURCE_DIR"
log "Destination: $BACKUP_DIR/$BACKUP_NAME"

# Use rsync for efficient backup with exclusions
sudo rsync -av \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.log' \
    --exclude='backup-server.sh' \
    --exclude='cron-backup.sh' \
    --progress \
    "$SOURCE_DIR/" "$BACKUP_DIR/$BACKUP_NAME/" 2>&1 | tee -a "$LOG_FILE"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    log "Backup completed successfully"

    # Calculate backup size
    BACKUP_SIZE=$(du -sh "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)
    log "Backup size: $BACKUP_SIZE"

    # Create a latest symlink for easy access
    if [ -L "$BACKUP_DIR/latest" ]; then
        sudo rm "$BACKUP_DIR/latest"
    fi
    sudo ln -s "$BACKUP_DIR/$BACKUP_NAME" "$BACKUP_DIR/latest"
    log "Created symlink: $BACKUP_DIR/latest -> $BACKUP_NAME"

    notify "Backup completed successfully: $BACKUP_NAME ($BACKUP_SIZE)"
else
    log "ERROR: Backup failed"
    notify "Backup failed - check logs at $LOG_FILE"
    exit 1
fi

# Cleanup old backups
log "Cleaning up backups older than $RETENTION_DAYS days..."
DELETED_COUNT=0
find "$BACKUP_DIR" -maxdepth 1 -type d -name "webservers-backup-*" -mtime +$RETENTION_DAYS | while read OLD_BACKUP; do
    log "Deleting old backup: $(basename $OLD_BACKUP)"
    sudo rm -rf "$OLD_BACKUP"
    DELETED_COUNT=$((DELETED_COUNT + 1))
done

if [ $DELETED_COUNT -gt 0 ]; then
    log "Deleted $DELETED_COUNT old backup(s)"
else
    log "No old backups to delete"
fi

# Show disk usage
log "Backup drive usage:"
df -h "$MOUNT_POINT" | tee -a "$LOG_FILE"

# List current backups
log "Current backups:"
ls -lht "$BACKUP_DIR" | grep "webservers-backup-" | head -n 10 | tee -a "$LOG_FILE"

# Optional: Unmount the drive (comment out if you want to keep it mounted)
# log "Unmounting external drive..."
# sudo umount "$MOUNT_POINT"
# log "External drive unmounted"

log "========================================="
log "Backup process completed"
log "========================================="

exit 0
