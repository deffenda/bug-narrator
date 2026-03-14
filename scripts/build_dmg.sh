#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_PATH="${PROJECT_PATH:-$ROOT_DIR/BugNarrator.xcodeproj}"
SCHEME="${SCHEME:-BugNarrator}"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$ROOT_DIR/build/DerivedData}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/dist}"
STAGING_DIR="${STAGING_DIR:-$ROOT_DIR/build/dmg-staging}"
CODE_SIGNING_ALLOWED="${CODE_SIGNING_ALLOWED:-NO}"
CODE_SIGN_STYLE="${CODE_SIGN_STYLE:-Automatic}"
DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM:-}"
ALLOW_PROVISIONING_UPDATES="${ALLOW_PROVISIONING_UPDATES:-NO}"
VOLUME_NAME="${VOLUME_NAME:-BugNarrator}"

if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "error: Xcode project not found at $PROJECT_PATH" >&2
    exit 1
fi

rm -rf "$STAGING_DIR"
mkdir -p "$OUTPUT_DIR" "$STAGING_DIR"

xcodebuild_args=(
    -project "$PROJECT_PATH"
    -scheme "$SCHEME"
    -configuration "$CONFIGURATION"
    -derivedDataPath "$DERIVED_DATA_PATH"
    CODE_SIGNING_ALLOWED="$CODE_SIGNING_ALLOWED"
    CODE_SIGN_STYLE="$CODE_SIGN_STYLE"
)

if [[ -n "$DEVELOPMENT_TEAM" ]]; then
    xcodebuild_args+=(
        DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"
    )
fi

if [[ "$ALLOW_PROVISIONING_UPDATES" == "YES" ]]; then
    xcodebuild_args+=(
        -allowProvisioningUpdates
    )
fi

xcodebuild "${xcodebuild_args[@]}" build

APP_PATH="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION/BugNarrator.app"

if [[ ! -d "$APP_PATH" ]]; then
    echo "error: built app not found at $APP_PATH" >&2
    exit 1
fi

INFO_PLIST="$APP_PATH/Contents/Info.plist"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INFO_PLIST")"
BUILD_NUMBER="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$INFO_PLIST")"

VERSIONED_DMG_NAME="BugNarrator-v${VERSION}-macOS.dmg"
STABLE_DMG_NAME="BugNarrator-macOS.dmg"
TEMP_DMG_PATH="$OUTPUT_DIR/BugNarrator-temp.dmg"
VERSIONED_DMG_PATH="$OUTPUT_DIR/$VERSIONED_DMG_NAME"
STABLE_DMG_PATH="$OUTPUT_DIR/$STABLE_DMG_NAME"

rm -f "$TEMP_DMG_PATH" "$VERSIONED_DMG_PATH" "$STABLE_DMG_PATH"

ditto "$APP_PATH" "$STAGING_DIR/BugNarrator.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$STAGING_DIR" \
    -format UDRW \
    -ov \
    "$TEMP_DMG_PATH"

hdiutil convert \
    "$TEMP_DMG_PATH" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "$VERSIONED_DMG_PATH"

cp "$VERSIONED_DMG_PATH" "$STABLE_DMG_PATH"
rm -f "$TEMP_DMG_PATH"
rm -rf "$STAGING_DIR"

echo "Built BugNarrator $VERSION ($BUILD_NUMBER)"
echo "Versioned DMG: $VERSIONED_DMG_PATH"
echo "Stable DMG: $STABLE_DMG_PATH"
