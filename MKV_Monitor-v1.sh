#!/bin/bash

# Check if inotifywait is installed
if ! command -v inotifywait &> /dev/null; then
    echo "inotifywait could not be found. Please install inotify-tools."
    exit 1
fi

# Directory to watch
WATCH_DIR="/path/to/your/directory"

# Log file
LOG_FILE="/path/to/your/logfile.log"

# Ensure the log file directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to log the filename and size of a new MKV file
log_new_mkv() {
    local file="$1"
    local filename
    filename=$(basename "$file") || { echo "$(date '+%Y-%m-%d %H:%M:%S') - basename failed for $file" >> "$LOG_FILE"; return; }
    local size
    size=$(stat -c%s "$file") || { echo "$(date '+%Y-%m-%d %H:%M:%S') - stat failed for $file" >> "$LOG_FILE"; return; }
    echo "$(date '+%Y-%m-%d %H:%M:%S') - New MKV file: $filename, Size: $size bytes" >> "$LOG_FILE"
}

# Main loop with restart capability
while true; do
    if [ ! -d "$WATCH_DIR" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - WATCH_DIR missing, retrying in 10s..." >> "$LOG_FILE"
        sleep 10
        continue
    fi

    # Run inotifywait with a restart loop
    inotifywait -m -r -e close_write,moved_to --format '%w%f' "$WATCH_DIR" | while read -r file; do
        if [[ "${file,,}" == *.mkv ]]; then
            log_new_mkv "$file"
        fi
    done

    echo "$(date '+%Y-%m-%d %H:%M:%S') - inotifywait exited unexpectedly, restarting in 5s..." >> "$LOG_FILE"
    sleep 5
done
