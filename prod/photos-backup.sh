#!/bin/sh

PROG_NAME="Photos Backup to Dropbox"
LOG="$HOME/Library/Logs/photos-backup.log"
MAX_WAIT_SECONDS=1800
NOTIFY_APP="$HOME/Software/test-LaunchAgents/SwiftNotify/SwiftNotify.app/Contents/MacOS/SwiftNotify"

notify() {
    if [ -x "$NOTIFY_APP" ]; then
        "$NOTIFY_APP" "$PROG_NAME" "$1"
    else
        osascript -e "display notification \"$1\" with title \"$PROG_NAME\" sound name \"Glass\""
    fi
}

# Like notify, but waits for user response when SwiftNotify is available.
# Returns 1 if user chose to skip, 0 otherwise.
notify_wait() {
    if [ -x "$NOTIFY_APP" ]; then
        "$NOTIFY_APP" --wait "$PROG_NAME" "$1"
        return $?
    else
        osascript -e "display notification \"$1\" with title \"$PROG_NAME\" sound name \"Glass\""
        return 0
    fi
}

if pgrep -x "Photos" > /dev/null; then
    echo "$(date): Photos is open, notifying user..." >> "$LOG"
    notify_wait "Photos is open. Close it to start the backup."
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
            notify "$PROG_NAME skipped — Photos was still open after $((MAX_WAIT_SECONDS / 60)) minutes."
            exit 0
        fi
    done

    echo "$(date): Photos closed, proceeding with backup." >> "$LOG"
fi

echo "$(date): Starting $PROG_NAME..." >> "$LOG"
notify "$PROG_NAME started."

rsync -a --delete --verbose \
    "$HOME/Pictures/Photos Library.photoslibrary" \
    "$HOME/Dropbox/" \
    >> "$LOG" 2>&1

STATUS=$?
if [ $STATUS -eq 0 ]; then
    echo "$(date): Backup complete." >> "$LOG"
    notify "$PROG_NAME completed successfully."
else
    echo "$(date): Backup failed (exit $STATUS)." >> "$LOG"
    notify "$PROG_NAME failed. Check ~/Library/Logs/photos-backup.log for details."
fi
