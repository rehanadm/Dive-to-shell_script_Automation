#!/bin/bash
#It rotates logs by:

#-Renaming current log with timestamp
#-Compressing old logs
#-Keeping only a fixed number of days
#-Creating a fresh log file
#-Setting permissions

# ==============================
# Log Rotation Script
# Supports: RHEL / Ubuntu / CentOS / OEL / Linux
# ==============================

# Log directory
LOG_DIR="/var/log/myapp"

# Log file to rotate
LOG_FILE="application.log"

# Retention period (days)
RETENTION_DAYS=7

# Timestamp
DATE=$(date +"%Y%m%d_%H%M%S")

# Full path
FULL_LOG="$LOG_DIR/$LOG_FILE"

# Check directory exists
if [ ! -d "$LOG_DIR" ]; then
    echo "ERROR: Log directory does not exist: $LOG_DIR"
    exit 1
fi

# Check file exists
if [ ! -f "$FULL_LOG" ]; then
    echo "ERROR: Log file not found: $FULL_LOG"
    exit 1
fi

echo "Starting log rotation..."

# Rotate log
mv "$FULL_LOG" "$LOG_DIR/${LOG_FILE}_${DATE}"

# Create new empty log file
touch "$FULL_LOG"

# Set ownership and permission
chmod 644 "$FULL_LOG"

# Compress rotated logs older than 1 minute
find "$LOG_DIR" -name "${LOG_FILE}_*" -type f ! -name "*.gz" -exec gzip {} \;

# Delete old compressed logs
find "$LOG_DIR" -name "${LOG_FILE}_*.gz" -mtime +$RETENTION_DAYS -exec rm -f {} \;

echo "Log rotation completed successfully."
