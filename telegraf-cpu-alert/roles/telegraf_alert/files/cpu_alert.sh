#!/bin/bash
LOG_FILE="/var/log/telegraf_cpu_alert.log"
EMAIL="mehziya0352@gmail.com"

while read line; do
  echo "$(date) :: ALERT >> $line" >> "$LOG_FILE"
  echo "$line" | mail -s "CPU Alert on $(hostname)" "$EMAIL"
done

