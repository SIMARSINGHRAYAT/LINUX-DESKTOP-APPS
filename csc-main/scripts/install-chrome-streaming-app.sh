#!/bin/sh
set -eu

if [ "$#" -ne 5 ]; then
  printf '%s\n' "Usage: $0 APP_ID DISPLAY_NAME APP_URL PROFILE_NAME LOGO_FILE" >&2
  exit 2
fi

APP_ID=$1
DISPLAY_NAME=$2
APP_URL=$3
PROFILE_NAME=$4
LOGO_FILE=$5

for browser in google-chrome google-chrome-stable chromium chromium-browser; do
  if command -v "$browser" >/dev/null 2>&1; then
    break
  fi
done

if ! command -v "$browser" >/dev/null 2>&1; then
  exit 127
fi

PROFILE_DIR=${STREAMING_PROFILE_DIR:-$HOME/.config/$PROFILE_NAME}
ICON_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/icons/linux-desktop-apps
APPLICATION_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/applications
ICON_PATH=$ICON_DIR/$APP_ID.png
DESKTOP_FILE=$APPLICATION_DIR/$APP_ID.desktop

mkdir -p "$PROFILE_DIR" "$ICON_DIR" "$APPLICATION_DIR"

if [ -n "${STREAMING_APP_REPOSITORY_DIR:-}" ] && [ -f "$STREAMING_APP_REPOSITORY_DIR/logo/$LOGO_FILE" ]; then
  cp "$STREAMING_APP_REPOSITORY_DIR/logo/$LOGO_FILE" "$ICON_PATH"
elif [ -f "$(dirname "$0")/../logo/$LOGO_FILE" ]; then
  cp "$(dirname "$0")/../logo/$LOGO_FILE" "$ICON_PATH"
else
  curl -fsSL "https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/logo/$LOGO_FILE" -o "$ICON_PATH"
fi

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=$DISPLAY_NAME
Comment=$DISPLAY_NAME web app
Exec=$browser --app=$APP_URL --user-data-dir=$PROFILE_DIR --no-first-run --no-default-browser-check --disable-gpu --class=$APP_ID
Icon=$ICON_PATH
Terminal=false
Type=Application
StartupWMClass=$APP_ID
Categories=AudioVideo;Network;
EOF

chmod 644 "$DESKTOP_FILE" "$ICON_PATH"
exec "$browser" --app="$APP_URL" --user-data-dir="$PROFILE_DIR" --no-first-run --no-default-browser-check --disable-gpu --class="$APP_ID"
