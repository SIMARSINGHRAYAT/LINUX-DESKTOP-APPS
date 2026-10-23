#!/bin/sh
set -eu

APP_ID=gta-5
APP_URL=https://v2.fiveplay.lol/launcher.html
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
MAIN_SOURCE=$SCRIPT_SOURCE_DIR/main.js
ICON_TEMP=
MAIN_TEMP=

cleanup() {
  [ -z "$ICON_TEMP" ] || rm -f "$ICON_TEMP"
  [ -z "$MAIN_TEMP" ] || rm -f "$MAIN_TEMP"
}
trap cleanup 0 HUP INT TERM

if ! command -v npm >/dev/null 2>&1; then
  printf '%s\n' 'Node.js and npm are required. Install them with: sudo apt install nodejs npm' >&2
  exit 127
fi

if [ ! -f "$ICON_SOURCE" ]; then
  ICON_TEMP=$(mktemp)
  ICON_SOURCE=$ICON_TEMP
  curl -fsSL \
    https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/logo/games.svg \
    -o "$ICON_SOURCE"
fi

if [ -f "$MAIN_SOURCE" ]; then
  :
else
  MAIN_TEMP=$(mktemp)
  MAIN_SOURCE=$MAIN_TEMP
  curl -fsSL \
    https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/Games/GTA5/main.js \
    -o "$MAIN_SOURCE"
fi

mkdir -p "$APP_DIR" "$ICON_DIR" "$APPLICATION_DIR" "$CONFIG_HOME/$APP_ID"
cp "$ICON_SOURCE" "$ICON_PATH"
cp "$MAIN_SOURCE" "$APP_DIR/main.js"

cat > "$APP_DIR/package.json" <<'EOF'
{
  "name": "gta-5-web-app",
  "productName": "GTA 5",
  "version": "1.0.0",
  "private": true,
  "main": "main.js"
}
EOF

npm install --prefix "$APP_DIR" --no-save --no-package-lock --no-audit --no-fund electron

cat > "$LAUNCHER_PATH" <<'EOF'
#!/bin/sh
set -eu

APP_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
LOG_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/gta-5
LOG_FILE=$LOG_DIR/launch.log
mkdir -p "$LOG_DIR"

if "$APP_DIR/node_modules/.bin/electron" "$APP_DIR" "$@" >"$LOG_FILE" 2>&1; then
  exit 0
else
  status=$?
  if command -v zenity >/dev/null 2>&1; then
    zenity --error --title='GTA 5 could not start' \
      --text="See $LOG_FILE for details." 2>/dev/null || true
  fi
  printf '%s\n' "GTA 5 failed to start (exit $status). See $LOG_FILE for details." >&2
  exit "$status"
fi
EOF
chmod 755 "$LAUNCHER_PATH"

EXEC_PATH=$(printf '%s' "$LAUNCHER_PATH" | sed 's/%/%%/g; s/\\/\\\\/g; s/"/\\"/g')
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Type=Application
Name=GTA 5
Comment=Launch the GTA 5 web game in Electron
Exec="$EXEC_PATH"
Icon=$ICON_PATH
Terminal=false
Categories=Game;Network;
StartupNotify=true
EOF
chmod 644 "$ICON_PATH" "$DESKTOP_FILE"

printf '%s\n' 'GTA 5 Electron app installed. Search for GTA 5 in your applications menu.'
printf '%s\n' "This app opens $APP_URL in Electron; it does not install Rockstar GTA V game files."
