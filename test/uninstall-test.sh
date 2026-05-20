#!/bin/bash

AGENTS_DIR="$HOME/Library/LaunchAgents"
PLIST_PATH="$AGENTS_DIR/com.user.photos-backup-test.plist"
SCRIPT_PATH="$HOME/Library/Scripts/photos-backup-test.sh"

launchctl unload "$PLIST_PATH" 2>/dev/null
rm -f "$PLIST_PATH"
rm -f "$SCRIPT_PATH"

echo "Test agent uninstalled."
