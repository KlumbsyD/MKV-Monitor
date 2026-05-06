# MKV-Monitor

Monitor a directory for new MKV files and automatically log their filename and size.
I made this for UnRAID, but it can be used in Linux. Requires `inotify-tools`.

---

## What It Does

MKV-Monitor watches a folder you specify. When a new `.mkv` file appears, it writes an entry to a log file recording the filename, file size, and timestamp.

Example log entry:
```
2025-05-06 14:32:11 - New MKV file: Movie.Title.2024.mkv, Size: 8589934592 bytes
```

---

## Requirements

- Linux (designed for UnRAID)
- `inotify-tools` package

To install `inotify-tools` on Unraid, run in terminal:
```bash
installpkg inotify-tools
```

---

## Setup

**1. Download the script**

Save `MKV_Monitorv-v1.sh` to your Unraid server. A good location is:
```
/mnt/user/appdata/mkv-monitor/MKV_Monitor-v1.sh
```

**2. Make it executable**

In terminal, run:
```bash
chmod +x /mnt/user/appdata/mkv-monitor/MKV_Monitor-v1.sh
```

**3. Edit the paths**

Open the script and update these two lines near the top:
```bash
WATCH_DIR="/path/to/your/directory"   # Folder to watch for new MKV files
LOG_FILE="/path/to/your/logfile.log"  # Where to save the log
```

Example for an Unraid media share:
```bash
WATCH_DIR="/mnt/user/Media/Movies"
LOG_FILE="/mnt/user/appdata/mkv-monitor/mkv-monitor.log"
```

---

## Running the Script

In terminal, run:
```bash
bash /mnt/user/appdata/mkv-monitor/MKV_Monitorv-v1.sh
```

The script will print:
```
Watching directory: /mnt/user/Media/Movies
```

It will continue running and watching until you stop it with `Ctrl+C`.

---

## Stopping the Script

Press `Ctrl+C` in the terminal where it is running.

---

## Log File

The log file is created automatically if it doesn't exist. Each new MKV file detected adds one line:
```
YYYY-MM-DD HH:MM:SS - New MKV file: filename.mkv, Size: [bytes] bytes
```

---

## Version History

| Version | Notes |
|---------|-------|
| v1.1 | Added recursive watching, close_write detection, .MKV case fix, basename error handling |
| v1.0 | Initial release - basic MKV detection and logging |

---

## License

MIT License - see [LICENSE](LICENSE) for details.
