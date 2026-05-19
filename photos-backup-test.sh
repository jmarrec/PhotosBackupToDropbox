#!/bin/bash

LOG="$HOME/Library/Logs/photos-backup-test.log"
MAX_WAIT_SECONDS=1800
NOTIFY_APP="$HOME/Software/test-LaunchAgents/SwiftNotify/SwiftNotify.app/Contents/MacOS/SwiftNotify"

notify() {
    "$NOTIFY_APP" "Photos Backup (TEST)" "$1"
}

if pgrep -x "Photos" > /dev/null; then
    echo "$(date): Photos is open, notifying user..." >> "$LOG"
    "$NOTIFY_APP" --wait "Photos Backup (TEST)" "Photos is open. Close it to start the backup."
    if [ $? -eq 1 ]; then
        echo "$(date): User chose to skip backup." >> "$LOG"
        notify "Backup skipped for tonight."
        exit 0
    fi

    # User dismissed — wait for Photos to actually close
    waited=0
    while pgrep -x "Photos" > /dev/null; do
        sleep 10
        waited=$((waited + 10))
        if [ $waited -ge $MAX_WAIT_SECONDS ]; then
            echo "$(date): Timed out waiting for Photos to close, skipping." >> "$LOG"
            notify "Photos backup skipped — Photos was still open after $((MAX_WAIT_SECONDS / 60)) minutes."
            exit 0
        fi
    done

    echo "$(date): Photos closed, proceeding with backup." >> "$LOG"
fi

echo "$(date): Starting Photos backup..." >> "$LOG"
notify "Photos backup started."

# DRY RUN
echo "$(date): [DRY RUN] rsync -a --delete \"$HOME/Pictures/Photos Library.photoslibrary\" \"$HOME/Dropbox/Photos Backup/\"" >> "$LOG"
echo "$(date): Backup complete." >> "$LOG"
notify "Photos backup completed successfully."
