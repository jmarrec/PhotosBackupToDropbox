#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PHOTOS_ICNS="/System/Applications/Photos.app/Contents/Resources/AppIcon.icns"
DROPBOX_ICNS="/Applications/Dropbox.app/Contents/Resources/AppIcon.icns"
WORK_DIR="$SCRIPT_DIR/icon-build"
OUTPUT_ICNS="$SCRIPT_DIR/AppIcon.icns"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "Extracting iconsets..."
iconutil -c iconset "$PHOTOS_ICNS" -o "$WORK_DIR/Photos.iconset"
iconutil -c iconset "$DROPBOX_ICNS" -o "$WORK_DIR/Dropbox.iconset"
mkdir -p "$WORK_DIR/Combined.iconset"

for PHOTO_PNG in "$WORK_DIR/Photos.iconset"/*.png; do
    FILENAME=$(basename "$PHOTO_PNG")
    DROPBOX_PNG="$WORK_DIR/Dropbox.iconset/$FILENAME"
    OUTPUT_PNG="$WORK_DIR/Combined.iconset/$FILENAME"

    if [ ! -f "$DROPBOX_PNG" ]; then
        echo "  Skipping $FILENAME (missing in Dropbox iconset)"
        cp "$PHOTO_PNG" "$OUTPUT_PNG"
        continue
    fi

    SIZE=$(magick identify -format "%w" "$PHOTO_PNG")
    HALF=$((SIZE / 2))

    magick \
        \( "$PHOTO_PNG" -crop "${HALF}x${SIZE}+0+0" +repage \) \
        \( "$DROPBOX_PNG" -crop "${HALF}x${SIZE}+${HALF}+0" +repage \) \
        +append "$OUTPUT_PNG"

    echo "  $FILENAME (${SIZE}px)"
done

echo "Building icns..."
iconutil -c icns "$WORK_DIR/Combined.iconset" -o "$OUTPUT_ICNS"
rm -rf "$WORK_DIR"
echo "Done: $OUTPUT_ICNS"
