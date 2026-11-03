#!/bin/bash

set -euo pipefail

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
echo "System health: $hostname ($timestamp)"
echo
echo "Disk: ${disk_usage}%"
echo "Memory: ${memory_usage}%"
echo "Load: ${load_average} on ${cores} cores"