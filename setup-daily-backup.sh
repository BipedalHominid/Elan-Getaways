#!/bin/bash

###############################################################################
# Setup Script for Daily Automated Backups
# Run this script once to configure daily backups
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/backup-server.sh"
CRON_TIME="0 2 * * *"  # Run at 2:00 AM daily

echo "========================================="
echo "Web Servers - Daily Backup Setup"
echo "========================================="
echo ""

# Make backup script executable
echo "[1/4] Making backup script executable..."
chmod +x "$BACKUP_SCRIPT"
echo "✓ Backup script is now executable"
echo ""

# Test if cron is available
echo "[2/4] Checking if cron is installed..."
if ! command -v crontab &> /dev/null; then
    echo "✗ ERROR: cron is not installed"
    echo "Please install cron: sudo apt-get install cron (Debian/Ubuntu)"
    echo "                     sudo yum install cronie (Red Hat/CentOS)"
    exit 1
fi
echo "✓ Cron is installed"
echo ""

# Add cron job
echo "[3/4] Setting up daily cron job..."
echo "The backup will run daily at 2:00 AM"
echo ""

# Check if cron job already exists
EXISTING_CRON=$(crontab -l 2>/dev/null | grep -F "$BACKUP_SCRIPT")
if [ -n "$EXISTING_CRON" ]; then
    echo "Cron job already exists:"
    echo "$EXISTING_CRON"
    echo ""
    read -p "Do you want to replace it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled"
        exit 0
    fi

    # Remove existing cron job
    crontab -l 2>/dev/null | grep -v -F "$BACKUP_SCRIPT" | crontab -
    echo "Removed existing cron job"
fi

# Add new cron job
(crontab -l 2>/dev/null; echo "$CRON_TIME $BACKUP_SCRIPT >> $SCRIPT_DIR/backup-cron.log 2>&1") | crontab -
echo "✓ Cron job added successfully"
echo ""

# Display current crontab
echo "[4/4] Current cron configuration:"
crontab -l | grep -F "$BACKUP_SCRIPT"
echo ""

echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Configuration Summary:"
echo "  • Backup script: $BACKUP_SCRIPT"
echo "  • Schedule: Daily at 2:00 AM"
echo "  • Log file: $SCRIPT_DIR/backup.log"
echo "  • Cron log: $SCRIPT_DIR/backup-cron.log"
echo "  • Retention: 30 days"
echo ""
echo "Next Steps:"
echo "  1. Connect your external hard drive (Toshiba UAS Controller)"
echo "  2. Run a test backup: $BACKUP_SCRIPT"
echo "  3. Check the logs: tail -f $SCRIPT_DIR/backup.log"
echo ""
echo "To change the backup schedule, run: crontab -e"
echo "To disable backups, run: crontab -r"
echo ""
echo "Useful cron schedule examples:"
echo "  0 2 * * *    - Daily at 2:00 AM (current setting)"
echo "  0 */6 * * *  - Every 6 hours"
echo "  0 0 * * 0    - Weekly on Sunday at midnight"
echo "  0 3 * * 1-5  - Weekdays at 3:00 AM"
echo ""
