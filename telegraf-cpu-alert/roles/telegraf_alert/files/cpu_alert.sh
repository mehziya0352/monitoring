#!/bin/bash

log_file="/tmp/cpu_alert.log"
threshold=80.0
alert_email="mehziya0352@gmail.com"

# Read the line from stdin (Telegraf will send Influx line format)
read input

# Extract CPU usage from the line
usage_user=$(echo "$input" | awk -F'usage_user=' '{print $2}' | tr -d '\r')

# Check if usage_user is empty
if [[ -z "$usage_user" ]]; then
  echo "$(date): No usage_user found in input: $input" >> "$log_file"
  exit 0
fi

# Compare CPU usage with threshold
is_high=$(echo "$usage_user > $threshold" | bc)

if [[ "$is_high" -eq 1 ]]; then
  echo "$(date): ALERT - CPU usage is high: ${usage_user}%" >> "$log_file"

  # Send email
  echo "High CPU Usage Detected on $(hostname): ${usage_user}%" | mail -s "CPU Alert on $(hostname)" "$alert_email"
  
  # Log email status
  echo "$(date): Email alert sent to $alert_email" >> "$log_file"
else
  echo "$(date): OK - CPU usage normal: ${usage_user}%" >> "$log_file"
fi

