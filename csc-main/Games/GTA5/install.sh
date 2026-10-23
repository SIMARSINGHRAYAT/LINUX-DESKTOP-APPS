#!/bin/sh
set -eu

APP_ID=gta-5
DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
APP_DIR=$DATA_HOME/linux-desktop-apps/$APP_ID
ICON_DIR=$DATA_HOME/icons/linux-desktop-apps
APPLICATION_DIR=$DATA_HOME/applications
ICON_PATH=$ICON_DIR/$APP_ID.svg
DESKTOP_FILE=$APPLICATION_DIR/$APP_ID.desktop
LAUNCHER_PATH=$APP_DIR/launch.sh
SCRIPT_SOURCE_DIR=$(CDPATH= cd -- "$(dirname "$0")" 2>/dev/null && pwd || true)
ICON_SOURCE=$SCRIPT_SOURCE_DIR/../../logo/games.svg

mkdir -p "$APP_DIR" "$ICON_DIR" "$APPLICATION_DIR" "$CONFIG_HOME/$APP_ID"

if [ -f "$ICON_SOURCE" ]; then
  cp "$ICON_SOURCE" "$ICON_PATH"
else
  curl -fsSL \
    https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/logo/games.svg \
    -o "$ICON_PATH"
fi

cat > "$LAUNCHER_PATH" <<'EOF'
#!/bin/sh
set -eu

APP_URL=https://v2.fiveplay.lol
PROFILE_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/gta-5

for browser in chromium chromium-browser google-chrome-stable google-chrome brave-browser; do
  if command -v "$browser" >/dev/null 2>&1; then
    exec "$browser" --app="$APP_URL" --user-data-dir="$PROFILE_DIR" --no-first-run
  fi
done

if command -v xdg-open >/dev/null 2>&1; then
  exec xdg-open "$APP_URL"
fi

printf '%s\n' 'Install Chromium or another browser, or install xdg-utils to launch GTA 5.' >&2
exit 127
EOF
chmod 755 "$LAUNCHER_PATH"

EXEC_PATH=$(printf '%s' "$LAUNCHER_PATH" | sed 's/%/%%/g; s/\\/\\\\/g; s/"/\\"/g')
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=GTA 5
Comment=Launch GTA 5 in a browser window
Exec="$EXEC_PATH"
Icon=$ICON_PATH
Terminal=false
Categories=Game;
StartupNotify=true
EOF
chmod 644 "$ICON_PATH" "$DESKTOP_FILE"

printf '%s\n' 'GTA 5 desktop launcher installed. Search for GTA 5 in your applications menu.'
printf '%s\n' 'This launcher opens the browser game; it does not install Rockstar GTA V game files.'
