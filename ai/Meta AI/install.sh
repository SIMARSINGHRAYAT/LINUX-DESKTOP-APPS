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
META_AI_SOURCE=$SCRIPT_SOURCE_DIR

if [ ! -f "$META_AI_SOURCE/package.json" ] || ! grep -q '"name": "meta-ai-desktop"' "$META_AI_SOURCE/package.json"; then
  if ! command -v git >/dev/null 2>&1; then
    printf '%s\n' 'Git is required to install Meta AI.' >&2
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
  META_AI_SOURCE="$REPOSITORY_DIR/ai/Meta AI"
fi

if [ ! -d "$META_AI_SOURCE" ] || [ ! -f "$META_AI_SOURCE/package.json" ]; then
  printf '%s\n' "Meta AI source is missing from $META_AI_SOURCE." >&2
  exit 1
fi

if [ "$(uname -s)" != Linux ] || ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'An apt-based Linux system (Ubuntu, Debian, or Kali) is required.' >&2
  exit 1
fi

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

if [ "$INSTALL_DISTRO" = kali ] && ! node_is_supported; then
  case "$(uname -m)" in
    x86_64) NODE_ARCH=x64 ;;
    aarch64|arm64) NODE_ARCH=arm64 ;;
    *) printf '%s\n' "Meta AI AppImage builds support x86_64 and ARM64, not $(uname -m)." >&2; exit 1 ;;
  esac
  if ! command -v curl >/dev/null 2>&1 || ! command -v sha256sum >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    printf '%s\n' 'curl, sha256sum, and tar are required to set up the local Node.js runtime.' >&2
    exit 1
  fi

  NODE_TOOLCHAIN_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/toolchains
  mkdir -p "$NODE_TOOLCHAIN_DIR"
  NODE_DOWNLOAD_DIR=$(mktemp -d "$NODE_TOOLCHAIN_DIR/.meta-ai-node.XXXXXX")
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
elif ! node_is_supported; then
  if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else
    printf '%s\n' 'Install Node.js 22.12+, npm, and sudo before continuing.' >&2
    exit 1
  fi
  $SUDO apt-get update
  $SUDO apt-get install -y nodejs npm
fi

if ! node_is_supported; then
  printf '%s\n' 'Node.js 22.12 or newer and npm are required to build Meta AI.' >&2
  exit 1
fi

cd "$META_AI_SOURCE"
PACKAGE_VERSION=$(node -e "console.log(require(process.argv[1]).version)" "$META_AI_SOURCE/package.json")
npm_install_args='--no-audit --no-fund'
npm_major=$(npm --version | cut -d. -f1)
if [ "$npm_major" -ge 11 ]; then npm_install_args="$npm_install_args --allow-git=all"; fi
npm ci $npm_install_args

if [ "$INSTALL_DISTRO" = kali ]; then
  npx electron-builder --linux AppImage
  APPIMAGE_PATH=$(find dist -maxdepth 1 -type f -name "Meta-AI-$PACKAGE_VERSION-*.AppImage" -print | sort | head -n 1)
  if [ -z "$APPIMAGE_PATH" ]; then printf '%s\n' 'No Meta AI AppImage was created.' >&2; exit 1; fi
  APPIMAGE_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/meta-ai-desktop
  APPIMAGE_INSTALL=$APPIMAGE_DIR/meta-ai-desktop.AppImage
  ICON_INSTALL=$APPIMAGE_DIR/icon.png
  LAUNCHER_DIR=${XDG_BIN_HOME:-$HOME/.local/bin}
  LOG_DIR=${XDG_CACHE_HOME:-$HOME/.cache}/linux-desktop-apps
  mkdir -p "$APPIMAGE_DIR" "$LAUNCHER_DIR" "$LOG_DIR" "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  cp "$APPIMAGE_PATH" "$APPIMAGE_INSTALL"
  cp "$META_AI_SOURCE/icon.png" "$ICON_INSTALL"
  chmod 755 "$APPIMAGE_INSTALL"
  cat > "$LAUNCHER_DIR/meta-ai-desktop" <<EOF
#!/bin/sh
set -eu
APPIMAGE="$APPIMAGE_INSTALL"
LOG_DIR="$LOG_DIR"
mkdir -p "\$LOG_DIR"
exec >>"\$LOG_DIR/meta-ai-desktop.log" 2>&1
printf '%s\\n' 'Starting Meta AI...'
exec "\$APPIMAGE" --appimage-extract-and-run --no-sandbox --disable-gpu --disable-gpu-compositing --disable-dev-shm-usage "\$@"
EOF
  chmod 755 "$LAUNCHER_DIR/meta-ai-desktop"
  cat > "${XDG_DATA_HOME:-$HOME/.local/share}/applications/meta-ai-desktop.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Meta AI
Comment=Meta AI chat desktop app
Exec=$LAUNCHER_DIR/meta-ai-desktop %U
Icon=$ICON_INSTALL
Terminal=false
Categories=Network;Chat;
StartupNotify=true
EOF
  printf '%s\n' 'Meta AI installed as an AppImage. Search for it in the application menu, or run meta-ai-desktop.'
  exit 0
fi

if [ "$INSTALL_DISTRO" != ubuntu ] && [ "$INSTALL_DISTRO" != debian ]; then
  printf '%s\n' 'Set LINUX_DESKTOP_DISTRO to ubuntu, debian, or kali before installing.' >&2
  exit 1
fi

npm run build:linux
DEB_PATH=$(find dist -maxdepth 1 -type f -name "Meta-AI-$PACKAGE_VERSION-*.deb" -print | sort | head -n 1)
if [ -z "$DEB_PATH" ]; then printf '%s\n' 'No Meta AI Debian package was created.' >&2; exit 1; fi
if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else
  printf '%s\n' 'Run as root or install sudo to install the Debian package.' >&2
  exit 1
fi
$SUDO apt-get install -y "$META_AI_SOURCE/$DEB_PATH"
printf '%s\n' 'Meta AI installed. Search for it in the application menu.'
