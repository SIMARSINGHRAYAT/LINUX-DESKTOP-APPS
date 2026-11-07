#!/bin/sh
set -eu

NODE_DOWNLOAD_DIR=

cleanup() {
  if [ -n "$NODE_DOWNLOAD_DIR" ]; then rm -rf "$NODE_DOWNLOAD_DIR"; fi
}

trap cleanup EXIT
trap 'exit 1' HUP INT TERM

REPOSITORY_URL=${ELECTRON_APPS_REPOSITORY_URL:-https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS.git}
REPOSITORY_DIR=${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/linux-desktop-apps}
SCRIPT_SOURCE_DIR=$(CDPATH= cd -- "$(dirname "$0")" 2>/dev/null && pwd || true)
GROK_SOURCE=$SCRIPT_SOURCE_DIR

if [ "$(uname -s)" != Linux ] || ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'An apt-based Linux system (Ubuntu, Debian, or Kali) is required.' >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1 || \
  ! command -v sha256sum >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
  if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else
    printf '%s\n' 'sudo is required to install Git, curl, certificates, and xz-utils.' >&2
    exit 1
  fi
  $SUDO apt-get -o DPkg::Lock::Timeout=600 update
  $SUDO apt-get -o DPkg::Lock::Timeout=600 install -y git curl ca-certificates xz-utils
fi

if [ ! -f "$GROK_SOURCE/package.json" ] || ! grep -q '"name": "grok-desktop"' "$GROK_SOURCE/package.json"; then
  if ! command -v git >/dev/null 2>&1; then printf '%s\n' 'Git is required to install Grok.' >&2; exit 1; fi
  if [ -d "$REPOSITORY_DIR/.git" ]; then
    git -C "$REPOSITORY_DIR" checkout -- ai/Grok/package-lock.json 2>/dev/null || true
    if [ -n "$(git -C "$REPOSITORY_DIR" status --porcelain)" ]; then
      git -C "$REPOSITORY_DIR" stash push --include-untracked -m 'Grok installer local changes' >/dev/null
    fi
    git -C "$REPOSITORY_DIR" pull --ff-only
  elif [ -e "$REPOSITORY_DIR" ]; then
    printf '%s\n' "$REPOSITORY_DIR exists but is not a Git checkout." >&2; exit 1
  else
    mkdir -p "$(dirname "$REPOSITORY_DIR")"
    git clone "$REPOSITORY_URL" "$REPOSITORY_DIR"
  fi
  GROK_SOURCE=$REPOSITORY_DIR/ai/Grok
fi

if [ ! -d "$GROK_SOURCE" ] || [ ! -f "$GROK_SOURCE/package.json" ]; then printf '%s\n' "Grok source is missing from $GROK_SOURCE." >&2; exit 1; fi
if [ "$(uname -s)" != Linux ] || ! command -v apt-get >/dev/null 2>&1; then printf '%s\n' 'An apt-based Linux system (Ubuntu, Debian, or Kali) is required.' >&2; exit 1; fi

if [ -r /etc/os-release ]; then . /etc/os-release; fi
SYSTEM_DISTRO=${ID:-}
INSTALL_DISTRO=${LINUX_DESKTOP_DISTRO:-$SYSTEM_DISTRO}
if [ -n "$SYSTEM_DISTRO" ] && [ -n "${LINUX_DESKTOP_DISTRO:-}" ] && [ "$INSTALL_DISTRO" != "$SYSTEM_DISTRO" ]; then
  printf '%s\n' "Requested distro '$INSTALL_DISTRO' does not match detected distro '$SYSTEM_DISTRO'; use '$SYSTEM_DISTRO'." >&2
  exit 1
fi
case "$INSTALL_DISTRO" in
  ubuntu|debian|kali) ;;
  *) printf '%s\n' 'Set LINUX_DESKTOP_DISTRO to ubuntu, debian, or kali before installing.' >&2; exit 1 ;;
esac

node_is_supported() {
  command -v node >/dev/null 2>&1 &&
    command -v npm >/dev/null 2>&1 &&
    node -e 'const [major, minor] = process.versions.node.split(".").map(Number); process.exit(major > 22 || (major === 22 && minor >= 12) ? 0 : 1)' >/dev/null 2>&1
}

if ! node_is_supported; then
  NODE_ARCH=$(uname -m)
  case "$NODE_ARCH" in
    x86_64) NODE_ARCH=x64 ;;
    aarch64|arm64) NODE_ARCH=arm64 ;;
    armv7l) NODE_ARCH=armv7l ;;
    *) printf '%s\n' "No Node.js 22 runtime is available for architecture $(uname -m)." >&2; exit 1 ;;
  esac
  if ! command -v curl >/dev/null 2>&1 || ! command -v sha256sum >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    printf '%s\n' 'curl, sha256sum, and tar are required to set up the Node.js runtime.' >&2
    exit 1
  fi

  NODE_TOOLCHAIN_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/toolchains
  mkdir -p "$NODE_TOOLCHAIN_DIR"
  NODE_DOWNLOAD_DIR=$(mktemp -d "$NODE_TOOLCHAIN_DIR/.grok-node.XXXXXX")
  NODE_DIST_URL=https://nodejs.org/dist/latest-v22.x
  curl -fsSL "$NODE_DIST_URL/SHASUMS256.txt" -o "$NODE_DOWNLOAD_DIR/SHASUMS256.txt"
  NODE_ARCHIVE=$(awk -v suffix="linux-$NODE_ARCH.tar.xz" '$2 ~ /^node-v22[.][0-9]+[.][0-9]+-/ && $2 ~ ("-" suffix "$") { print $2; exit }' "$NODE_DOWNLOAD_DIR/SHASUMS256.txt")
  if [ -z "$NODE_ARCHIVE" ]; then printf '%s\n' "No Node.js 22 archive is available for $NODE_ARCH." >&2; exit 1; fi
  NODE_SHA256=$(awk -v archive="$NODE_ARCHIVE" '$2 == archive { print $1; exit }' "$NODE_DOWNLOAD_DIR/SHASUMS256.txt")
  if [ -z "$NODE_SHA256" ]; then printf '%s\n' "No checksum found for $NODE_ARCHIVE." >&2; exit 1; fi

  NODE_RUNTIME_DIR=$NODE_TOOLCHAIN_DIR/${NODE_ARCHIVE%.tar.xz}
  if [ ! -x "$NODE_RUNTIME_DIR/bin/node" ] || [ ! -x "$NODE_RUNTIME_DIR/bin/npm" ]; then
    curl -fsSL "$NODE_DIST_URL/$NODE_ARCHIVE" -o "$NODE_DOWNLOAD_DIR/$NODE_ARCHIVE"
    (cd "$NODE_DOWNLOAD_DIR" && printf '%s  %s\n' "$NODE_SHA256" "$NODE_ARCHIVE" | sha256sum -c -)
    mkdir "$NODE_DOWNLOAD_DIR/runtime"
    tar -xJf "$NODE_DOWNLOAD_DIR/$NODE_ARCHIVE" --strip-components=1 -C "$NODE_DOWNLOAD_DIR/runtime"
    if [ -e "$NODE_RUNTIME_DIR" ]; then rm -rf "$NODE_RUNTIME_DIR"; fi
    mv "$NODE_DOWNLOAD_DIR/runtime" "$NODE_RUNTIME_DIR"
  fi
  PATH=$NODE_RUNTIME_DIR/bin:$PATH
  export PATH
fi

if ! node_is_supported; then
  printf '%s\n' 'Node.js 22.12 or newer and npm are required to build Grok.' >&2
  exit 1
fi

cd "$GROK_SOURCE"
PACKAGE_VERSION=$(node -e "console.log(require(process.argv[1]).version)" "$GROK_SOURCE/package.json")
npm_install_args='--no-audit --no-fund'
npm_major=$(npm --version | cut -d. -f1)
if [ "$npm_major" -ge 11 ]; then npm_install_args="$npm_install_args --allow-git=all"; fi
if [ -f package-lock.json ]; then npm ci $npm_install_args; else npm install $npm_install_args; fi

if [ -r /etc/os-release ]; then . /etc/os-release; fi
INSTALL_DISTRO=${LINUX_DESKTOP_DISTRO:-${ID:-}}
if [ "$INSTALL_DISTRO" = kali ]; then
  npx electron-builder --linux AppImage
  APPIMAGE_PATH=$(find dist -maxdepth 1 -type f -name "Grok-$PACKAGE_VERSION-*.AppImage" -print | sort | head -n 1)
  if [ -z "$APPIMAGE_PATH" ]; then printf '%s\n' 'No Grok AppImage was created.' >&2; exit 1; fi
  APPIMAGE_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/grok-desktop
  APPIMAGE_INSTALL=$APPIMAGE_DIR/grok-desktop.AppImage
  ICON_INSTALL=$APPIMAGE_DIR/icon.png
  LAUNCHER_DIR=${XDG_BIN_HOME:-$HOME/.local/bin}
  mkdir -p "$APPIMAGE_DIR" "$LAUNCHER_DIR" "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  cp "$APPIMAGE_PATH" "$APPIMAGE_INSTALL"
  cp "$GROK_SOURCE/logo.png" "$ICON_INSTALL"
  chmod 755 "$APPIMAGE_INSTALL"
  cat > "$LAUNCHER_DIR/grok-desktop" <<EOF
#!/bin/sh
exec "$APPIMAGE_INSTALL" --appimage-extract-and-run --no-sandbox "\$@"
EOF
  chmod 755 "$LAUNCHER_DIR/grok-desktop"
  cat > "${XDG_DATA_HOME:-$HOME/.local/share}/applications/grok-desktop.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Grok
Comment=Grok AI desktop app
Exec=$LAUNCHER_DIR/grok-desktop %U
Icon=$ICON_INSTALL
Terminal=false
Categories=Network;Chat;
StartupNotify=true
EOF
  printf '%s\n' 'Grok installed as an AppImage. Search for it in the application menu.'
  exit 0
fi

if [ "$INSTALL_DISTRO" != ubuntu ] && [ "$INSTALL_DISTRO" != debian ]; then printf '%s\n' 'Set LINUX_DESKTOP_DISTRO to ubuntu, debian, or kali before installing.' >&2; exit 1; fi
npm run build:linux
DEB_PATH=$(find dist -maxdepth 1 -type f -name "Grok-$PACKAGE_VERSION-*.deb" -print | sort | head -n 1)
if [ -z "$DEB_PATH" ]; then printf '%s\n' 'No Grok Debian package was created.' >&2; exit 1; fi
if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else printf '%s\n' 'Run as root or install sudo to install the Debian package.' >&2; exit 1; fi
$SUDO apt-get install -y "$GROK_SOURCE/$DEB_PATH"
if command -v update-desktop-database >/dev/null 2>&1; then
  $SUDO update-desktop-database
fi
printf '%s\n' 'Grok installed. Search for it in the application menu.'
