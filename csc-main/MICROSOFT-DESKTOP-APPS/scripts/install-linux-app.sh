#!/bin/sh
set -eu

if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
  printf '%s\n' "Usage: $0 APP_DIRECTORY DEB_PACKAGE DISPLAY_NAME LOGO_FILE [LOCAL_SOURCE_DIR]" >&2
  exit 2
fi

APP_DIRECTORY=$1
DEB_PACKAGE=$2
DISPLAY_NAME=$3
LOGO_FILE=$4
LOCAL_SOURCE_DIR_OVERRIDE=${5:-}
LOCAL_SOURCE_DIR=$LOCAL_SOURCE_DIR_OVERRIDE
REPOSITORY_URL=${ELECTRON_APPS_REPOSITORY_URL:-https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS.git}
REPOSITORY_DIR=${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/linux-desktop-apps}

if [ "$(uname -s)" != Linux ]; then
  printf '%s\n' 'This installer supports Linux only.' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'An apt-based Debian-family system is required (Ubuntu, Debian, or Kali).' >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else
    printf '%s\n' 'Install Node.js, npm, git, and sudo before continuing.' >&2
    exit 1
  fi
  $SUDO apt-get update
  $SUDO apt-get install -y git ca-certificates curl nodejs npm build-essential
fi

if [ -z "$LOCAL_SOURCE_DIR" ]; then
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
  if [ "$APP_DIRECTORY" = Qwen ] && [ -d "$REPOSITORY_DIR/ai/Qwen" ]; then
    LOCAL_SOURCE_DIR=$REPOSITORY_DIR/ai/Qwen
  else
    LOCAL_SOURCE_DIR=$REPOSITORY_DIR/csc-main/MICROSOFT-DESKTOP-APPS/$APP_DIRECTORY
  fi
  if [ ! -d "$LOCAL_SOURCE_DIR" ]; then
    LOCAL_SOURCE_DIR=$(find "$REPOSITORY_DIR" -type d -name "$APP_DIRECTORY" -not -path '*/node_modules/*' -print -quit)
  fi
fi

if [ ! -d "$LOCAL_SOURCE_DIR" ]; then
  printf '%s\n' "Application directory not found: $LOCAL_SOURCE_DIR" >&2
  exit 1
fi

node_major=$(node -p "process.versions.node.split('.')[0]")
if [ "$node_major" -lt 22 ]; then
  printf '%s\n' 'Node.js 22 or newer is required to build these applications.' >&2
  exit 1
fi

ICON_DIR=$LOCAL_SOURCE_DIR/assets/icons
mkdir -p "$ICON_DIR"
if [ -n "$LOGO_FILE" ]; then
  LOGO_SOURCE=$REPOSITORY_DIR/csc-main/logo/$LOGO_FILE
  if [ -n "$LOCAL_SOURCE_DIR_OVERRIDE" ]; then
    LOGO_SOURCE=$(CDPATH= cd -- "$LOCAL_SOURCE_DIR/../../.." && pwd)/csc-main/logo/$LOGO_FILE
  fi
  if [ ! -f "$LOGO_SOURCE" ]; then
    printf '%s\n' "Provided logo not found: $LOGO_SOURCE" >&2
    exit 1
  fi
  cp "$LOGO_SOURCE" "$ICON_DIR/512.png"
  if command -v convert >/dev/null 2>&1; then
    for size in 16 32 48 64 128 256; do
      convert "$LOGO_SOURCE" -resize "${size}x${size}" "$ICON_DIR/$size.png"
    done
  fi
fi

cd "$LOCAL_SOURCE_DIR"
npm_major=$(npm --version | cut -d. -f1)
npm_install_args='--no-audit --no-fund'
if [ "$npm_major" -ge 11 ]; then
  npm_install_args="$npm_install_args --allow-git=all"
fi
npm install $npm_install_args

if [ -r /etc/os-release ]; then
  . /etc/os-release
fi
INSTALL_DISTRO=${LINUX_DESKTOP_DISTRO:-${ID:-}}

if [ "$INSTALL_DISTRO" = kali ]; then
  npx electron-builder --linux AppImage
  APPIMAGE_PATH=$(find dist -maxdepth 1 -type f -name '*.AppImage' -print | sort | head -n 1)
  if [ -z "$APPIMAGE_PATH" ]; then
    printf '%s\n' "No AppImage was created for $DISPLAY_NAME." >&2
    exit 1
  fi

  APPIMAGE_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/$DEB_PACKAGE
  APPIMAGE_INSTALL=$APPIMAGE_DIR/$DEB_PACKAGE.AppImage
  LAUNCHER_DIR=${XDG_BIN_HOME:-$HOME/.local/bin}
  LAUNCHER=$LAUNCHER_DIR/$DEB_PACKAGE
  mkdir -p "$APPIMAGE_DIR" "$LAUNCHER_DIR" "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  cp "$APPIMAGE_PATH" "$APPIMAGE_INSTALL"
  chmod 755 "$APPIMAGE_INSTALL"
  cat > "$LAUNCHER" <<EOF
#!/bin/sh
set -eu
APPIMAGE="$APPIMAGE_INSTALL"
LOG_DIR="\${XDG_CACHE_HOME:-\$HOME/.cache}/linux-desktop-apps"
mkdir -p "\$LOG_DIR"
exec >>"\$LOG_DIR/$DEB_PACKAGE.log" 2>&1
printf '%s\\n' "Starting $DISPLAY_NAME..."
exec "\$APPIMAGE" --appimage-extract-and-run --no-sandbox --disable-gpu --disable-gpu-compositing --disable-dev-shm-usage "\$@"
EOF
  chmod 755 "$LAUNCHER"
  DESKTOP_FILE=${XDG_DATA_HOME:-$HOME/.local/share}/applications/$DEB_PACKAGE.desktop
  ICON_ENTRY=
  if [ -n "$LOGO_FILE" ]; then ICON_ENTRY="Icon=$ICON_DIR/512.png"; fi
  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$DISPLAY_NAME
Comment=Unofficial $DISPLAY_NAME for Linux
Exec=$LAUNCHER %U
$ICON_ENTRY
Terminal=false
Categories=Office;Network;
StartupNotify=true
EOF
  chmod 644 "$DESKTOP_FILE"
  if command -v gio >/dev/null 2>&1; then
    gio set "$DESKTOP_FILE" metadata::trusted true 2>/dev/null || true
  fi
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${XDG_DATA_HOME:-$HOME/.local/share}/applications" 2>/dev/null || true
  fi
  printf '%s\n' "$DISPLAY_NAME installed as an AppImage. Search for it in the application menu."
  exit 0
fi

if [ "$INSTALL_DISTRO" != ubuntu ] && [ "$INSTALL_DISTRO" != debian ] && [ "$INSTALL_DISTRO" != kali ]; then
  printf '%s\n' 'Set LINUX_DESKTOP_DISTRO to ubuntu, debian, or kali before installing.' >&2
  exit 1
fi

npm run build:linux
DEB_PATH=$(find dist -maxdepth 1 -type f -name '*.deb' -print | sort | head -n 1)
if [ -z "$DEB_PATH" ]; then
  printf '%s\n' "No Debian package was created for $DISPLAY_NAME." >&2
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else
  printf '%s\n' 'Run as root or install sudo to install the desktop package.' >&2
  exit 1
fi
$SUDO apt-get install -y "$(CDPATH= cd -- "$LOCAL_SOURCE_DIR" && pwd)/$DEB_PATH"
printf '%s\n' "$DISPLAY_NAME installed. Search for it in the application menu."