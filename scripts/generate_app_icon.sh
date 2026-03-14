#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_IMAGE="${1:-$ROOT_DIR/Resources/AppIconSource.png}"
ICONSET_DIR="$ROOT_DIR/Resources/Assets.xcassets/AppIcon.appiconset"

if [[ ! -f "$SOURCE_IMAGE" ]]; then
    echo "error: source image not found at $SOURCE_IMAGE" >&2
    echo "Place a square 1024x1024 PNG at Resources/AppIconSource.png or pass a path as the first argument." >&2
    exit 1
fi

mkdir -p "$ICONSET_DIR"

generate_icon() {
    local size="$1"
    local filename="$2"
    sips -s format png -z "$size" "$size" "$SOURCE_IMAGE" --out "$ICONSET_DIR/$filename" >/dev/null
}

generate_icon 16 "icon_16x16.png"
generate_icon 32 "icon_16x16@2x.png"
generate_icon 32 "icon_32x32.png"
generate_icon 64 "icon_32x32@2x.png"
generate_icon 128 "icon_128x128.png"
generate_icon 256 "icon_128x128@2x.png"
generate_icon 256 "icon_256x256.png"
generate_icon 512 "icon_256x256@2x.png"
generate_icon 512 "icon_512x512.png"
generate_icon 1024 "icon_512x512@2x.png"

echo "Generated AppIcon assets in $ICONSET_DIR"
