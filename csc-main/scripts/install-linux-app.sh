#!/bin/sh
set -eu

if [ "$#" -lt 3 ] || [ "$#" -gt 5 ]; then
  printf '%s\n' "Usage: $0 APP_DIRECTORY APP_ID DISPLAY_NAME [EXECUTABLE_NAME] [BUNDLE_DIRECTORY]" >&2
  exit 2
fi

APP_DIRECTORY=$1
APP_ID=$2
DISPLAY_NAME=$3
APP_NAME=$(basename "$APP_DIRECTORY" | tr '[:upper:]' '[:lower:]')
EXECUTABLE_NAME=${4:-$APP_NAME}
BUNDLE_DIRECTORY=${5:-$APP_NAME}
REPOSITORY_URL=${ELECTRON_APPS_REPOSITORY_URL:-https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS.git}
REPOSITORY_DIR=${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/linux-desktop-apps}
INSTALL_DIR=$REPOSITORY_DIR/csc-main/$APP_DIRECTORY

if [ "$(uname -s)" != Linux ]; then
  printf '%s\n' 'This installer supports Linux only.' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'An apt-based Debian-family system is required (Ubuntu or Kali).' >&2
  exit 1
fi

needs_prerequisites=0
for tool in flatpak flatpak-builder git unzip xvfb-run xauth Xvfb; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    needs_prerequisites=1
    break
  fi
done

if [ "$needs_prerequisites" -eq 1 ]; then
  if [ "$(id -u)" -eq 0 ]; then
    SUDO=
  elif command -v sudo >/dev/null 2>&1; then
    SUDO=sudo
  else
    printf '%s\n' 'Run as root or install sudo before continuing.' >&2
    exit 1
  fi
  printf '%s\n' "Installing prerequisites for $DISPLAY_NAME..."
  $SUDO apt-get update
  $SUDO apt-get install -y flatpak flatpak-builder git ca-certificates unzip xvfb xauth
fi

if [ -d "$REPOSITORY_DIR/.git" ]; then
  current_remote=$(git -C "$REPOSITORY_DIR" remote get-url origin 2>/dev/null || true)
  if [ -n "$current_remote" ] && [ "$current_remote" != "$REPOSITORY_URL" ]; then
    printf '%s\n' "Repository at $REPOSITORY_DIR points to $current_remote; choose another directory with ELECTRON_APPS_REPOSITORY_DIR." >&2
    exit 1
  fi
  git -C "$REPOSITORY_DIR" pull --ff-only
elif [ -e "$REPOSITORY_DIR" ]; then
  printf '%s\n' "$REPOSITORY_DIR exists but is not a Git checkout." >&2
  exit 1
else
  mkdir -p "$(dirname "$REPOSITORY_DIR")"
  git clone "$REPOSITORY_URL" "$REPOSITORY_DIR"
fi

if [ ! -d "$INSTALL_DIR" ] && [ -d "$REPOSITORY_DIR/$APP_DIRECTORY" ]; then
  INSTALL_DIR=$REPOSITORY_DIR/$APP_DIRECTORY
fi

if [ ! -d "$INSTALL_DIR" ]; then
  printf '%s\n' "Application directory not found: $INSTALL_DIR" >&2
  exit 1
fi

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub org.freedesktop.Sdk//25.08 org.freedesktop.Platform//25.08

cd "$INSTALL_DIR"
flatpak-builder --user --install --force-clean --disable-rofiles-fuse build manifest.yaml

# Create a system-level launcher that runs the Electron binary directly
# and starts a real Xvfb server when no graphical session is available.
LAUNCHER_DIR="$HOME/.local/bin"
mkdir -p "$LAUNCHER_DIR"
LAUNCHER_SCRIPT="$LAUNCHER_DIR/$EXECUTABLE_NAME"

cat > "$LAUNCHER_SCRIPT" << EOF
#!/bin/sh
set -eu

APP_DIR="${INSTALL_DIR}"
ELECTRON_BIN="\$APP_DIR/build/files/lib/$BUNDLE_DIRECTORY/electron/electron"

if [ ! -x "\$ELECTRON_BIN" ]; then
  echo "Electron app bundle not found at \$ELECTRON_BIN" >&2
  exit 1
fi

if [ -z "\${DISPLAY:-}" ]; then
  DISPLAY_NUM=99
  while [ -f "/tmp/.X\${DISPLAY_NUM}-lock" ]; do
    DISPLAY_NUM=\$((DISPLAY_NUM + 1))
  done

  export DISPLAY=":\${DISPLAY_NUM}"
  export XAUTHORITY="\$(mktemp /tmp/github-xauth.XXXXXX)"
  xauth add "\$DISPLAY" . "\$(xxd -l 16 -p /dev/urandom)" >/dev/null 2>&1 || true

  # Start a real virtual X server if one is not already running.
  if ! pgrep -x Xvfb >/dev/null 2>&1; then
    Xvfb "\$DISPLAY" -screen 0 1280x720x24 >/tmp/${EXECUTABLE_NAME}-xvfb.log 2>&1 &
  fi

  sleep 1
fi

exec "\$ELECTRON_BIN" --no-sandbox --disable-gpu --disable-software-rasterizer --ozone-platform=x11 "\$APP_DIR" "\$@"
EOF

chmod 755 "$LAUNCHER_SCRIPT"

DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"
DESKTOP_FILE="$DESKTOP_DIR/$APP_ID.desktop"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=GitHub
Comment=Unofficial GitHub wrapper for Linux
Exec=$LAUNCHER_SCRIPT %U
Icon=$APP_ID
Terminal=false
Categories=Development;Network;
StartupNotify=true
StartupWMClass=$EXECUTABLE_NAME
X-Flatpak=$APP_ID
EOF
chmod 644 "$DESKTOP_FILE"
update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

printf '%s\n' "✓ GitHub launcher installed to $LAUNCHER_SCRIPT"
printf '%s\n' "✓ Desktop entry installed to $DESKTOP_FILE"

exec "$LAUNCHER_SCRIPT"