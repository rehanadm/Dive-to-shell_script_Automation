#!/bin/bash

LOGS=(
"/var/log/messages"
"/var/log/secure"
"/var/log/myapp.log"
)

BACKUP_DIR="/var/log/archive"
MAX_BACKUPS=5
DATE=$(date +%F_%H-%M-%S)

mkdir -p "$BACKUP_DIR"

for LOG in "${LOGS[@]}"
do
    if [ -f "$LOG" ]; then

        FILE=$(basename "$LOG")

        cp "$LOG" "$BACKUP_DIR/${FILE}_${DATE}"
        : > "$LOG"

        gzip "$BACKUP_DIR/${FILE}_${DATE}"

        echo "Rotated: $FILE"

    fi
done

# Cleanup old archives
find "$BACKUP_DIR" -name "*.gz" -type f -mtime +30 -delete
