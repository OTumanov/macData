#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Building release binary..."
swift build -c release

APP="$ROOT/build/MacDataCalendar.app"
BIN="$ROOT/.build/release/MacDataCalendar"
PLIST_SRC="$ROOT/Sources/MacDataCalendar/Info.plist"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$BIN" "$APP/Contents/MacOS/MacDataCalendar"
cp "$PLIST_SRC" "$APP/Contents/Info.plist"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP"
  echo "Signed: $APP"
fi

echo "Built: $APP"
echo "Run: open \"$APP\""
