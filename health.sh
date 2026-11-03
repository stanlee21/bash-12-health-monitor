#!/bin/bash

set -euo pipefail

# Set warning limits with default values
DISK_LIMIT="${DISK_LIMIT:-85}"
MEM_LIMIT="${MEM_LIMIT:-80}"

# Handle command-line arguments
quiet=false

case "${1:-}" in
    "")
        ;;
    --quiet)
        quiet=true
        ;;
    *)
        printf "Usage: %s [--quiet]\n" "${0##*/}" >&2
        exit 2
        ;;
esac

if (( $# > 1 )); then
    printf "Usage: %s [--quiet]\n" "${0##*/}" >&2
    exit 2
fi

# Create log directory
mkdir -p "$HOME/logs"
LOG_FILE="$HOME/logs/health.log"

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

# Track warnings
warning=0

# Logging function
log_check() {
    local level="$1"
    local message="$2"
    local log_timestamp

    log_timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    printf '%s %s %s\n' "$log_timestamp" "$level" "$message" >> "$LOG_FILE"

    if [[ "$quiet" == false ]]; then
        printf '%s\n' "$message"
    fi
}

# Display report heading
if [[ "$quiet" == false ]]; then
    printf "System health: %s (%s)\n\n" "$hostname" "$timestamp"
fi

# Check disk usage
if (( disk_usage > DISK_LIMIT )); then
    warning=1
    log_check "WARN" "Disk ${disk_usage}% WARN (limit ${DISK_LIMIT}%)"
else
    log_check "INFO" "Disk ${disk_usage}% OK"
fi

# Check memory usage
if (( memory_usage > MEM_LIMIT )); then
    warning=1
    log_check "WARN" "Memory ${memory_usage}% WARN (limit ${MEM_LIMIT}%)"
else
    log_check "INFO" "Memory ${memory_usage}% OK"
fi

# Check system load per core
if awk -v l="$load_average" -v n="$cores" 'BEGIN { exit !(l / n > 1.0) }'; then
    warning=1
    log_check "WARN" "Load ${load_average} on ${cores} cores WARN (limit 1.0 per core)"
else
    log_check "INFO" "Load ${load_average} on ${cores} cores OK"
fi

# Return the overall health status
exit "$warning"
