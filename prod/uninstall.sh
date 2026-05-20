#!/bin/bash

AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$AGENTS_DIR/com.user.photos-backup.plist"
SCRIPT_PATH="$HOME/Library/Scripts/photos-backup.sh"

launchctl unload "$PLIST_PATH" 2>/dev/null
rm -f "$PLIST_PATH"
rm -f "$SCRIPT_PATH"

echo "Photos backup agent uninstalled."
