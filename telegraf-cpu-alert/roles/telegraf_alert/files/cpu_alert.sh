#!/bin/bash

log_file="/var/log/cpu_alert.log"
threshold=80.0
alert_email="mehziya0352@gmail.com"

while read input; do
  usage_user=$(echo "$input" | awk -F'usage_user=' '{print $2}' | tr -d '\r')

  if [[ -z "$usage_user" ]]; then
    echo "$(date): No usage_user found in input: $input" >> "$log_file"
    continue
  fi

  is_high=$(echo "$usage_user > $threshold" | bc)

  if [[ "$is_high" -eq 1 ]]; then
    echo "$(date): ALERT - CPU usage is high: ${usage_user}%" >> "$log_file"

    echo -e "Subject: CPU Alert on $(hostname)\n\nHigh CPU Usage Detected: ${usage_user}%" \
      | msmtp "$alert_email"

    echo "$(date): Email alert sent to $alert_email" >> "$log_file"
  else
    echo "$(date): OK - CPU usage normal: ${usage_user}%" >> "$log_file"
  fi
done
