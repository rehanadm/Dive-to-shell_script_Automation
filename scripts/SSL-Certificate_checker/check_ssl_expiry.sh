#!/bin/bash

CERT_LIST="/opt/ssl-monitor/certificates.txt"
LOG_FILE="/opt/ssl-monitor/ssl_expiry_report.log"

DAYS_THRESHOLD=30

> "$LOG_FILE"

echo "SSL Certificate Expiry Report - $(date)" >> "$LOG_FILE"
echo "===================================================" >> "$LOG_FILE"

while read -r HOST
do
    [ -z "$HOST" ] && continue

    EXPIRY_DATE=$(echo | openssl s_client -connect ${HOST}:443 -servername ${HOST} 2>/dev/null \
        | openssl x509 -noout -enddate 2>/dev/null \
        | cut -d= -f2)

    if [ -z "$EXPIRY_DATE" ]; then
        echo "$HOST : Unable to retrieve certificate" >> "$LOG_FILE"
        continue
    fi

    EXPIRY_EPOCH=$(date -d "$EXPIRY_DATE" +%s)
    CURRENT_EPOCH=$(date +%s)

    DAYS_LEFT=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))

    if [ "$DAYS_LEFT" -le "$DAYS_THRESHOLD" ]; then
        echo "WARNING: $HOST expires in $DAYS_LEFT days ($EXPIRY_DATE)" >> "$LOG_FILE"
    else
        echo "OK: $HOST expires in $DAYS_LEFT days" >> "$LOG_FILE"
    fi

done < "$CERT_LIST"

MAIL_TO="linux-admin@company.com"

grep "WARNING:" "$LOG_FILE" > /tmp/ssl_alerts.txt

if [ -s /tmp/ssl_alerts.txt ]; then
    mail -s "SSL Certificate Expiry Alert" "$MAIL_TO" < "$LOG_FILE"
fi
