#!/bin/bash

# Set umask to restrict log file permissions
umask 077

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
    local size

    # Extract filename and size, stripping control characters from the filename
    filename=$(basename "$file" | tr -d '\000-\037')
    size=$(stat -c%s "$file")

    # Log the entry using printf to avoid log injection
    printf '%s - New MKV file: %s, Size: %s bytes\n' \
        "$(date '+%Y-%m-%d %H:%M:%S')" "$filename" "$size" >> "$LOG_FILE"
}

# Signal handling to ensure proper cleanup
trap 'kill $(jobs -p) 2>/dev/null; exit 0' SIGTERM SIGINT

# Check for inotify watch limit
SUBDIRS=$(find "$WATCH_DIR" -type d | wc -l)
MAX_WATCHES=$(cat /proc/sys/fs/inotify/max_user_watches)
if [ "$SUBDIRS" -gt "$MAX_WATCHES" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - WARNING: $SUBDIRS dirs exceeds watch limit $MAX_WATCHES" >> "$LOG_FILE"
fi

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

    # Check inotifywait exit code
    INOTIFY_EXIT=${PIPESTATUS[0]}
    if [ "$INOTIFY_EXIT" -ne 0 ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - inotifywait exited with error $INOTIFY_EXIT" >> "$LOG_FILE"
    fi

    # Log rotation check (simple size check)
    if [ "$(stat -c%s "$LOG_FILE")" -gt 10485760 ]; then  # 10 MB
        mv "$LOG_FILE" "${LOG_FILE}.1"
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') - inotifywait exited, restarting in 5s..." >> "$LOG_FILE"
    sleep 5
done
