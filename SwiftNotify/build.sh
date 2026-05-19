#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="SwiftNotify"
APP_BUNDLE="$SCRIPT_DIR/$APP_NAME.app"
MACOS_DIR="$APP_BUNDLE/Contents/MacOS"
RESOURCES_DIR="$APP_BUNDLE/Contents/Resources"

rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

echo "Compiling..."
swiftc "$SCRIPT_DIR/main.swift" -o "$MACOS_DIR/$APP_NAME" || exit 1

echo "Copying resources..."
cp "$SCRIPT_DIR/Info.plist" "$APP_BUNDLE/Contents/"
cp "$SCRIPT_DIR/AppIcon.icns" "$RESOURCES_DIR/AppIcon.icns"

echo "Signing..."
codesign --force --deep --sign - "$APP_BUNDLE" || exit 1

echo "Done: $APP_BUNDLE"
echo "Run: $APP_BUNDLE/Contents/MacOS/$APP_NAME \"Title\" \"Message\""
