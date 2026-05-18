#!/bin/bash
#Reusable Linux Log Rotation Shell Script for rotating logs, compressing old files, and keeping only a defined number of backups.

# Configuration
LOG_FILE="/var/log/myapp.log"
BACKUP_DIR="/var/log/archive"
MAX_BACKUPS=7
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Check if log file exists
if [ -f "$LOG_FILE" ]; then

    echo "Rotating log: $LOG_FILE"

    # Move current log to backup folder
    mv "$LOG_FILE" "$BACKUP_DIR/myapp.log_$DATE"

    # Create new empty log file
    touch "$LOG_FILE"

    # Set permissions
    chmod 644 "$LOG_FILE"

    # Compress rotated logs
    gzip "$BACKUP_DIR/myapp.log_$DATE"

    echo "Compression completed."

    # Delete old backups (keep only latest N files)
    ls -tp "$BACKUP_DIR"/*.gz | grep -v '/$' | tail -n +$((MAX_BACKUPS+1)) | xargs -r rm --

    echo "Old backups cleaned."

else
    echo "Log file not found: $LOG_FILE"
fi
