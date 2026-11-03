#!/bin/bash

set -euo pipefail

# Set warning limits with default values
DISK_LIMIT="${DISK_LIMIT:-85}"
MEM_LIMIT="${MEM_LIMIT:-80}"

# Get system information
hostname=$(hostname)
timestamp=$(date '+%Y-%m-%d %H:%M')

# Get disk usage
disk_usage=$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')

# Get memory usage
memory_usage=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100}')

# Get system load
load_average=$(awk '{print $1}' /proc/loadavg)

# Get CPU core count
cores=$(nproc)

# Display system health report
printf "System health: %s (%s)\n\n" "$hostname" "$timestamp"

# Check disk usage
if (( disk_usage > DISK_LIMIT )); then
    printf "Disk     %s%%   WARN (limit %s%%)\n" "$disk_usage" "$DISK_LIMIT"
else
    printf "Disk     %s%%   OK\n" "$disk_usage"
fi

# Check memory usage
if (( memory_usage > MEM_LIMIT )); then
    printf "Memory   %s%%   WARN (limit %s%%)\n" "$memory_usage" "$MEM_LIMIT"
else
    printf "Memory   %s%%   OK\n" "$memory_usage"
fi

# Check system load per core
if awk -v l="$load_average" -v n="$cores" 'BEGIN { exit !(l / n > 1.0) }'; then
    printf "Load     %s on %s cores   WARN (limit 1.0 per core)\n" "$load_average" "$cores"
else
    printf "Load     %s on %s cores   OK\n" "$load_average" "$cores"
fi
