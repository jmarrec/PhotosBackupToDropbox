# Photos Backup to Dropbox

Automatically backs up `~/Pictures/Photos Library.photoslibrary` to `~/Dropbox/` using rsync, triggered daily via a macOS launchd agent. Notifies via a native macOS notification (SwiftNotify) with options to close Photos and start the backup, or skip for the night.

## Structure

```
SwiftNotify/        Native macOS notification app (required by both prod and test)
prod/               Production scripts and launchd plist
test/               Test scripts and launchd plist (dry-run, runs every 2 minutes)
```

## Setup

### 1. Build SwiftNotify

```bash
SwiftNotify/build.sh
```

### 2. Grant Full Disk Access

rsync requires Full Disk Access to read the Photos library. When run from Terminal it inherits Terminal's permissions, but the launchd agent runs as a background process with no inherited permissions.

**System Settings → Privacy & Security → Full Disk Access** → enable `/bin/sh`.

Note: `/bin/sh` may already appear in the list but be toggled off — make sure it is actually enabled. Child processes (including rsync) inherit its permissions, so no other binaries need to be added.

### 3. Install

Production (runs daily at 6pm):
```bash
prod/install.sh
```

Test (dry-run, runs every 2 minutes):
```bash
test/install-test.sh
```

## Uninstall

```bash
prod/uninstall.sh
test/uninstall-test.sh
```

## Logs

```
~/Library/Logs/photos-backup.log
~/Library/Logs/photos-backup-test.log
```
