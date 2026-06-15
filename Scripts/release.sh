#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PLIST="$ROOT/Sources/MacDataCalendar/Info.plist"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$PLIST")"
APP_NAME="MacDataCalendar"
ZIP_NAME="${APP_NAME}-${VERSION}.zip"

echo "==> Building ${APP_NAME} ${VERSION}"
bash "$ROOT/Scripts/build-app.sh"

mkdir -p "$ROOT/dist"
ZIP_PATH="$ROOT/dist/$ZIP_NAME"
rm -f "$ZIP_PATH"

echo "==> Packaging ${ZIP_PATH}"
ditto -c -k --keepParent "$ROOT/build/${APP_NAME}.app" "$ZIP_PATH"

echo "==> Checksum"
shasum -a 256 "$ZIP_PATH"

echo ""
echo "Release ready:"
echo "  App:  $ROOT/build/${APP_NAME}.app"
echo "  Zip:  $ZIP_PATH"
echo ""
echo "Install: unzip ${ZIP_NAME} && cp -R ${APP_NAME}.app /Applications/"
