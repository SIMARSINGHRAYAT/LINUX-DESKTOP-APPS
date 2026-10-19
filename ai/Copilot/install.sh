#!/bin/sh
set -eu

REPOSITORY_URL=${ELECTRON_APPS_REPOSITORY_URL:-https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS.git}
REPOSITORY_DIR=${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/linux-desktop-apps}
SCRIPT_SOURCE_DIR=$(CDPATH= cd -- "$(dirname "$0")" 2>/dev/null && pwd || true)
COPILOT_SOURCE=$SCRIPT_SOURCE_DIR

if [ ! -f "$COPILOT_SOURCE/package.json" ] || ! grep -q '"name": "copilot-desktop"' "$COPILOT_SOURCE/package.json"; then
  if ! command -v git >/dev/null 2>&1; then printf '%s\n' 'Git is required to install Copilot.' >&2; exit 1; fi
  if [ -d "$REPOSITORY_DIR/.git" ]; then
    if [ -n "$(git -C "$REPOSITORY_DIR" status --porcelain)" ]; then
      INSTALL_TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/copilot-install.XXXXXX")
      trap 'rm -rf "$INSTALL_TEMP_DIR"' EXIT HUP INT TERM
      printf '%s\n' 'Existing repository has local changes; using a temporary clean checkout.' >&2
      git clone --depth 1 "$REPOSITORY_URL" "$INSTALL_TEMP_DIR/repository"
      COPILOT_SOURCE=$INSTALL_TEMP_DIR/repository/ai/Copilot
    else
      git -C "$REPOSITORY_DIR" pull --ff-only
      COPILOT_SOURCE=$REPOSITORY_DIR/ai/Copilot
    fi
  elif [ -e "$REPOSITORY_DIR" ]; then
    printf '%s\n' "$REPOSITORY_DIR exists but is not a Git checkout." >&2; exit 1
  else
    mkdir -p "$(dirname "$REPOSITORY_DIR")"
    git clone "$REPOSITORY_URL" "$REPOSITORY_DIR"
    COPILOT_SOURCE=$REPOSITORY_DIR/ai/Copilot
  fi
fi

if [ ! -d "$COPILOT_SOURCE" ] || [ ! -f "$COPILOT_SOURCE/package.json" ]; then printf '%s\n' "Copilot source is missing from $COPILOT_SOURCE." >&2; exit 1; fi
if [ "$(uname -s)" != Linux ] || ! command -v apt-get >/dev/null 2>&1; then printf '%s\n' 'An apt-based Linux system (Ubuntu, Debian, or Kali) is required.' >&2; exit 1; fi
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else printf '%s\n' 'Install Node.js 22+, npm, and sudo before continuing.' >&2; exit 1; fi
  $SUDO apt-get update
  $SUDO apt-get install -y nodejs npm
fi
node_major=$(node -p "process.versions.node.split('.')[0]")
if [ "$node_major" -lt 22 ]; then printf '%s\n' 'Node.js 22 or newer is required to build Copilot.' >&2; exit 1; fi

PACKAGE_VERSION=$(node -e "console.log(require(process.argv[1]).version)" "$COPILOT_SOURCE/package.json")
cd "$COPILOT_SOURCE"
npm_install_args='--no-audit --no-fund'
npm_major=$(npm --version | cut -d. -f1)
if [ "$npm_major" -ge 11 ]; then npm_install_args="$npm_install_args --allow-git=all"; fi
if [ -f package-lock.json ]; then npm ci $npm_install_args; else npm install $npm_install_args; fi

if [ -r /etc/os-release ]; then . /etc/os-release; fi
INSTALL_DISTRO=${LINUX_DESKTOP_DISTRO:-${ID:-}}
if [ "$INSTALL_DISTRO" = kali ]; then
  npx electron-builder --linux AppImage
  APPIMAGE_PATH=$(find dist -maxdepth 1 -type f -name "Copilot-$PACKAGE_VERSION-*.AppImage" -print | sort | head -n 1)
  if [ -z "$APPIMAGE_PATH" ]; then printf '%s\n' 'No Copilot AppImage was created.' >&2; exit 1; fi
  APPIMAGE_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/copilot-desktop
  APPIMAGE_INSTALL=$APPIMAGE_DIR/copilot-desktop.AppImage
  ICON_INSTALL=$APPIMAGE_DIR/copilot.png
  LAUNCHER_DIR=${XDG_BIN_HOME:-$HOME/.local/bin}
  mkdir -p "$APPIMAGE_DIR" "$LAUNCHER_DIR" "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  cp "$APPIMAGE_PATH" "$APPIMAGE_INSTALL"
  cp "$COPILOT_SOURCE/Microsoft_Copilot_logo_PNG_(1).png" "$ICON_INSTALL"
  chmod 755 "$APPIMAGE_INSTALL"
  cat > "$LAUNCHER_DIR/copilot-desktop" <<EOF
#!/bin/sh
exec "$APPIMAGE_INSTALL" --appimage-extract-and-run --no-sandbox "\$@"
EOF
  chmod 755 "$LAUNCHER_DIR/copilot-desktop"
  cat > "${XDG_DATA_HOME:-$HOME/.local/share}/applications/copilot-desktop.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Copilot
Comment=Microsoft Copilot AI desktop app
Exec=$LAUNCHER_DIR/copilot-desktop %U
Icon=$ICON_INSTALL
Terminal=false
Categories=Network;Chat;
StartupNotify=true
EOF
  printf '%s\n' 'Copilot installed as an AppImage. Search for it in the application menu.'
  exit 0
fi
if [ "$INSTALL_DISTRO" != ubuntu ] && [ "$INSTALL_DISTRO" != debian ]; then printf '%s\n' 'Set LINUX_DESKTOP_DISTRO to ubuntu, debian, or kali before installing.' >&2; exit 1; fi
npm run build:linux
DEB_PATH=$(find dist -maxdepth 1 -type f -name "Copilot-$PACKAGE_VERSION-*.deb" -print | sort | head -n 1)
if [ -z "$DEB_PATH" ]; then printf '%s\n' 'No Copilot Debian package was created.' >&2; exit 1; fi
if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else printf '%s\n' 'Run as root or install sudo to install the Debian package.' >&2; exit 1; fi
$SUDO apt-get install -y "$COPILOT_SOURCE/$DEB_PATH"
if command -v update-desktop-database >/dev/null 2>&1; then
  $SUDO update-desktop-database
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1 && [ -d /usr/share/icons/hicolor ]; then
  $SUDO gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi
printf '%s\n' 'Copilot installed. Search for it in the application menu.'
