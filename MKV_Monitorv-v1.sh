#!/bin/bash

# Directory to watch
WATCH_DIR="/path/to/your/directory"

# Log file
LOG_FILE="/path/to/your/logfile.log"

# Ensure the log file exists
touch "$LOG_FILE"

# Function to log the filename and size of a new MKV file
log_new_mkv() {
    local file="$1"
    local filename
    filename=$(basename "$file") || { echo "basename failed for $file" >> "$LOG_FILE"; return; }
    local size=$(stat -c%s "$file")
    echo "$(date '+%Y-%m-%d %H:%M:%S') - New MKV file: $filename, Size: $size bytes" >> "$LOG_FILE"
}

# Watch the directory for new MKV files
echo "Watching directory: $WATCH_DIR"
inotifywait -m -r -e close_write,moved_to --format '%w%f' "$WATCH_DIR" | while read -r file; do
    if [[ "$file" =~ \.mkv$ || "$file" =~ \.MKV$ ]]; then
        log_new_mkv "$file"
    fi
done
