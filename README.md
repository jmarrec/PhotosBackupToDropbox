# Photos Backup to Dropbox

Automatically backs up `~/Pictures/Photos Library.photoslibrary` to `~/Dropbox/` using rsync, triggered daily via a macOS launchd agent. Notifies via a native macOS notification (SwiftNotify) with options to close Photos and start the backup, or skip for the night.

## Why not store the library directly in Dropbox?

The Photos library is a package — a directory containing an SQLite database and thousands of individual files. Dropbox syncs files individually and continuously, with no awareness of SQLite transaction boundaries. If Photos is open and writing to its database while Dropbox is syncing, Dropbox can upload a partial or mid-write state, resulting in a corrupted database on the other end. Apple only supports syncing the Photos library via iCloud, which has the necessary coordination built in.

This project works around that by keeping the library in its normal location (`~/Pictures/`) and using rsync to copy it to Dropbox only when Photos is fully closed, ensuring a consistent snapshot is always transferred.

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

I just went overboard because I found osascript notification to be ugly... So I created a Swift app that would use the MacOS Notification center (and I created an Icon to go with it)

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
