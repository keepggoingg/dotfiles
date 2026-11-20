#!/usr/bin/env bash
# Build "Open in Neovim.app" into ~/Applications and register it with Finder,
# so any file or folder has Open With > Open in Neovim.
set -euo pipefail
cd "$(dirname "$0")"
APP="$HOME/Applications/Open in Neovim.app"
PLIST="$APP/Contents/Info.plist"
mkdir -p "$HOME/Applications"
rm -rf "$APP"
osacompile -o "$APP" open-in-neovim.applescript
/usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$PLIST"
/usr/libexec/PlistBuddy \
  -c "Add :CFBundleDocumentTypes array" \
  -c "Add :CFBundleDocumentTypes:0 dict" \
  -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string Item" \
  -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string Editor" \
  -c "Add :CFBundleDocumentTypes:0:LSHandlerRank string Alternate" \
  -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes array" \
  -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:0 string public.item" \
  -c "Add :CFBundleDocumentTypes:0:LSItemContentTypes:1 string public.folder" \
  "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier dev.personal.open-in-neovim" "$PLIST" 2>/dev/null ||
  /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string dev.personal.open-in-neovim" "$PLIST"
codesign --force --sign - "$APP" 2>/dev/null
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP"
echo "built $APP"
