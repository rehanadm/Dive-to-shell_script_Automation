#!/bin/bash

# ==============================
# MongoDB Monitoring Script
# ==============================

EMAIL="abdul.rehan@xyz.com"
PORT="27017"
SERVICE="mongod"
LOG_FILE="/var/log/mongo_monitor.log"

RETRY=3
SLEEP_INTERVAL=5
COOLDOWN=300   # seconds (5 min) to avoid restart loop

DATE=$(date "+%Y-%m-%d %H:%M:%S")
HOST=$(hostname)

# ==============================
# FUNCTIONS
# ==============================

log_msg() {
    echo "$DATE [$HOST] : $1" >> "$LOG_FILE"
}

check_port() {
    ss -lnt | grep -q ":$PORT"
}

check_process() {
    pgrep -x "$SERVICE" >/dev/null 2>&1
}

restart_service() {
    log_msg "Attempting to restart $SERVICE"

    if systemctl restart "$SERVICE"; then
        sleep 5

        if check_port && check_process; then
            log_msg "SUCCESS: $SERVICE restarted successfully"
            echo "MongoDB restarted successfully on $HOST at $DATE" \
            | mail -s "RECOVERY: MongoDB Restarted" "$EMAIL"
            return 0
        else
            log_msg "FAILED: $SERVICE restart did not recover service"
            return 1
        fi
    else
        log_msg "ERROR: systemctl restart failed"
        return 1
    fi
}

# ==============================
# RETRY CHECK
# ==============================

COUNT=0
while [ $COUNT -lt $RETRY ]; do
    if check_port && check_process; then
        log_msg "MongoDB is UP"
        exit 0
    fi

    COUNT=$((COUNT+1))
    sleep $SLEEP_INTERVAL
done

# ==============================
# SERVICE DOWN
# ==============================

log_msg "ALERT: MongoDB DOWN after $RETRY retries"

# Prevent restart loops
LAST_RESTART_FILE="/tmp/mongo_last_restart"

if [ -f "$LAST_RESTART_FILE" ]; then
    LAST_TIME=$(cat "$LAST_RESTART_FILE")
    NOW=$(date +%s)

    if [ $((NOW - LAST_TIME)) -lt $COOLDOWN ]; then
        log_msg "Cooldown active, skipping restart"
        echo "MongoDB DOWN on $HOST but restart skipped due to cooldown" \
        | mail -s "WARNING: MongoDB DOWN (Cooldown Active)" "$EMAIL"
        exit 1
    fi
fi

# ==============================
# TRY RESTART
# ==============================

date +%s > "$LAST_RESTART_FILE"

if restart_service; then
    exit 0
else
    log_msg "CRITICAL: MongoDB still DOWN after restart"

    echo "CRITICAL: MongoDB DOWN on $HOST at $DATE. Restart failed." \
    | mail -s "CRITICAL: MongoDB DOWN" "$EMAIL"

    exit 2
fi
