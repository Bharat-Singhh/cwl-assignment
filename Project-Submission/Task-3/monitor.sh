#!/bin/bash
# monitor.sh
# Logs CPU and memory usage of all running containers with timestamps.
# Scheduled to run every minute via cron.

LOG_DIR="/opt/container-monitor/logs"
LOG_FILE="\/container-monitor.log"

mkdir -p "\"

TIMESTAMP=\

docker stats --no-stream --format \
  "{{.Name}} {{.CPUPerc}} {{.MemUsage}} {{.MemPerc}}" \
| while read -r name cpu mem_usage mem_perc; do
    echo "[\] CONTAINER: \ | CPU: \ | MEM: \ (\)"
done >> "\"

if ! docker ps -q | grep -q .; then
    echo "[\] No running containers detected." >> "\"
fi
