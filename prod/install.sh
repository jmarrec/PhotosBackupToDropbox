#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/Library/Scripts"
AGENTS_DIR="$HOME/Library/LaunchAgents"
LOG_DIR="$HOME/Library/Logs"
SCRIPT_PATH="$INSTALL_DIR/photos-backup.sh"
PLIST_NAME="com.user.photos-backup.plist"
PLIST_PATH="$AGENTS_DIR/$PLIST_NAME"
LOG_PATH="$LOG_DIR/photos-backup.log"

mkdir -p "$INSTALL_DIR" "$AGENTS_DIR" "$LOG_DIR"

cp "$SCRIPT_DIR/photos-backup.sh" "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

NOTIFY_APP_PATH="$(cd "$SCRIPT_DIR/.." && pwd)/SwiftNotify/SwiftNotify.app/Contents/MacOS/SwiftNotify"

sed -i '' \
    -e "s|NOTIFY_APP_PATH|$NOTIFY_APP_PATH|g" \
    "$SCRIPT_PATH"

sed \
    -e "s|SCRIPT_PATH|$SCRIPT_PATH|g" \
    -e "s|LOG_PATH|$LOG_PATH|g" \
    "$SCRIPT_DIR/com.user.photos-backup.plist" > "$PLIST_PATH"

echo "$(date): --- Agent unloading for reinstall ---" >> "$LOG_PATH"
launchctl unload "$PLIST_PATH" 2>/dev/null
echo "$(date): --- Agent reloaded ---" >> "$LOG_PATH"
launchctl load "$PLIST_PATH"

echo "Installed. Backup will run daily at 6pm."
echo "Watch the log: tail -f $LOG_PATH"
