#!/bin/bash

# ==============================
# WildFly Monitoring Script
# ==============================

EMAIL="abdul.rehan@xyz.com"
SERVICE="wildfly"
PORT="8080"
HOST="127.0.0.1"
URL="http://$HOST:$PORT"
LOG_FILE="/var/log/wildfly_monitor.log"

RETRY=3
SLEEP_INTERVAL=5
COOLDOWN=300

DATE=$(date "+%Y-%m-%d %H:%M:%S")
HOSTNAME=$(hostname)

# ==============================
# FUNCTIONS
# ==============================

log_msg() {
    echo "$DATE [$HOSTNAME] : $1" >> "$LOG_FILE"
}

check_service() {
    systemctl is-active --quiet "$SERVICE"
}

check_port() {
    ss -lnt | grep -q ":$PORT"
}

check_http() {
    curl -s --max-time 5 "$URL" | grep -q "Welcome"
}

# Optional: WildFly CLI health check
check_cli() {
    /opt/wildfly/bin/jboss-cli.sh --connect \
    --command=":read-attribute(name=server-state)" 2>/dev/null \
    | grep -q "running"
}

restart_service() {
    log_msg "Attempting restart of $SERVICE"

    if systemctl restart "$SERVICE"; then
        sleep 10

        if check_service && check_port && check_http; then
            log_msg "SUCCESS: WildFly restarted"
            echo "WildFly recovered on $HOSTNAME at $DATE" \
            | mail -s "RECOVERY: WildFly Restarted" "$EMAIL"
            return 0
        else
            log_msg "FAILED: Restart unsuccessful"
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
    if check_service && check_port && check_http; then
        log_msg "WildFly is UP"
        exit 0
    fi

    COUNT=$((COUNT+1))
    sleep $SLEEP_INTERVAL
done

# ==============================
# DOWN DETECTED
# ==============================

log_msg "ALERT: WildFly DOWN after $RETRY retries"

LAST_RESTART_FILE="/tmp/wildfly_last_restart"

if [ -f "$LAST_RESTART_FILE" ]; then
    LAST_TIME=$(cat "$LAST_RESTART_FILE")
    NOW=$(date +%s)

    if [ $((NOW - LAST_TIME)) -lt $COOLDOWN ]; then
        log_msg "Cooldown active, skipping restart"

        echo "WildFly DOWN on $HOSTNAME but restart skipped (cooldown active)" \
        | mail -s "WARNING: WildFly DOWN" "$EMAIL"

        exit 1
    fi
fi

# ==============================
# RESTART ATTEMPT
# ==============================

date +%s > "$LAST_RESTART_FILE"

if restart_service; then
    exit 0
else
    log_msg "CRITICAL: WildFly still DOWN after restart"

    echo "CRITICAL: WildFly DOWN on $HOSTNAME at $DATE. Restart failed." \
    | mail -s "CRITICAL: WildFly DOWN" "$EMAIL"

    exit 2
fi
