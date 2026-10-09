#!/bin/sh
set -eu

REPOSITORY_URL=${ELECTRON_APPS_REPOSITORY_URL:-https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS.git}
REPOSITORY_DIR=${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/linux-desktop-apps}
SCRIPT_SOURCE_DIR=$(CDPATH= cd -- "$(dirname "$0")" 2>/dev/null && pwd || true)
QWEN_SOURCE=$SCRIPT_SOURCE_DIR

if [ ! -f "$QWEN_SOURCE/package.json" ]; then
  if ! command -v git >/dev/null 2>&1; then
    printf '%s\n' 'Git is required to install Qwen.' >&2
    exit 1
  fi
  if [ -d "$REPOSITORY_DIR/.git" ]; then
    git -C "$REPOSITORY_DIR" pull --ff-only
  elif [ -e "$REPOSITORY_DIR" ]; then
    printf '%s\n' "$REPOSITORY_DIR exists but is not a Git checkout." >&2
    exit 1
  else
    mkdir -p "$(dirname "$REPOSITORY_DIR")"
    git clone "$REPOSITORY_URL" "$REPOSITORY_DIR"
  fi
  QWEN_SOURCE=$REPOSITORY_DIR/ai/Qwen
fi

if [ ! -d "$QWEN_SOURCE" ] || [ ! -f "$QWEN_SOURCE/package.json" ]; then
  printf '%s\n' "Qwen source is missing from $QWEN_SOURCE." >&2
  exit 1
fi

if [ "$(uname -s)" != Linux ] || ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'An apt-based Linux system (Ubuntu, Debian, or Kali) is required.' >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else
    printf '%s\n' 'Install Node.js 22+, npm, and sudo before continuing.' >&2
    exit 1
  fi
  $SUDO apt-get update
  $SUDO apt-get install -y nodejs npm
fi

node_major=$(node -p "process.versions.node.split('.')[0]")
if [ "$node_major" -lt 22 ]; then
  printf '%s\n' 'Node.js 22 or newer is required to build Qwen.' >&2
  exit 1
fi

cd "$QWEN_SOURCE"
npm install --no-audit --no-fund

if [ -r /etc/os-release ]; then . /etc/os-release; fi
INSTALL_DISTRO=${LINUX_DESKTOP_DISTRO:-${ID:-}}
if [ "$INSTALL_DISTRO" = kali ]; then
  npx electron-builder --linux AppImage
  APPIMAGE_PATH=$(find dist -maxdepth 1 -type f -name '*.AppImage' -print | sort | head -n 1)
  if [ -z "$APPIMAGE_PATH" ]; then printf '%s\n' 'No Qwen AppImage was created.' >&2; exit 1; fi
  APPIMAGE_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/qwen-desktop
  APPIMAGE_INSTALL=$APPIMAGE_DIR/qwen-desktop.AppImage
  LAUNCHER_DIR=${XDG_BIN_HOME:-$HOME/.local/bin}
  mkdir -p "$APPIMAGE_DIR" "$LAUNCHER_DIR" "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  cp "$APPIMAGE_PATH" "$APPIMAGE_INSTALL"
  chmod 755 "$APPIMAGE_INSTALL"
  cat > "$LAUNCHER_DIR/qwen-desktop" <<EOF
#!/bin/sh
exec "$APPIMAGE_INSTALL" --appimage-extract-and-run --no-sandbox "\$@"
EOF
  chmod 755 "$LAUNCHER_DIR/qwen-desktop"
  cat > "${XDG_DATA_HOME:-$HOME/.local/share}/applications/qwen-desktop.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Qwen
Comment=Qwen AI chat desktop app
Exec=$LAUNCHER_DIR/qwen-desktop %U
Terminal=false
Categories=Network;Chat;
StartupNotify=true
EOF
  printf '%s\n' 'Qwen installed as an AppImage. Search for it in the application menu.'
  exit 0
fi

if [ "$INSTALL_DISTRO" != ubuntu ] && [ "$INSTALL_DISTRO" != debian ]; then
  printf '%s\n' 'Set LINUX_DESKTOP_DISTRO to ubuntu, debian, or kali before installing.' >&2
  exit 1
fi

npm run build:linux
DEB_PATH=$(find dist -maxdepth 1 -type f -name '*.deb' -print | sort | head -n 1)
if [ -z "$DEB_PATH" ]; then printf '%s\n' 'No Qwen Debian package was created.' >&2; exit 1; fi
if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else
  printf '%s\n' 'Run as root or install sudo to install the Debian package.' >&2
  exit 1
fi
$SUDO apt-get install -y "$QWEN_SOURCE/$DEB_PATH"
printf '%s\n' 'Qwen installed. Search for it in the application menu.'
