#!/bin/sh
set -eu

NODE_DOWNLOAD_DIR=

cleanup_node_download() {
  if [ -n "$NODE_DOWNLOAD_DIR" ]; then rm -rf "$NODE_DOWNLOAD_DIR"; fi
}

trap cleanup_node_download EXIT
trap 'exit 1' HUP INT TERM

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

if [ -r /etc/os-release ]; then
  . /etc/os-release
fi
RAW_DISTRO=${LINUX_DESKTOP_DISTRO:-${ID:-}}
RAW_DISTRO=$(echo "$RAW_DISTRO" | tr '[:upper:]' '[:lower:]')

case "$RAW_DISTRO" in
  ubuntu)
    DISTRO="ubuntu"
    PKG_TYPE="deb"
    ;;
  debian)
    DISTRO="debian"
    PKG_TYPE="deb"
    ;;
  mint|linuxmint)
    DISTRO="mint"
    PKG_TYPE="deb"
    ;;
  kali)
    DISTRO="kali"
    PKG_TYPE="appimage"
    ;;
  fedora)
    DISTRO="fedora"
    PKG_TYPE="rpm"
    ;;
  arch|archlinux|manjaro|endeavouros)
    DISTRO="arch"
    PKG_TYPE="pacman"
    ;;
  *)
    if command -v apt-get >/dev/null 2>&1; then
      DISTRO="debian"
      PKG_TYPE="deb"
    elif command -v dnf >/dev/null 2>&1; then
      DISTRO="fedora"
      PKG_TYPE="rpm"
    elif command -v pacman >/dev/null 2>&1; then
      DISTRO="arch"
      PKG_TYPE="pacman"
    else
      printf '%s\n' "Unsupported Linux distribution: $RAW_DISTRO. Supported distributions: Ubuntu, Debian, Linux Mint, Fedora, Arch Linux, Kali Linux." >&2
      exit 1
    fi
    ;;
esac

if [ "$(id -u)" -eq 0 ]; then
  SUDO=
elif command -v sudo >/dev/null 2>&1; then
  SUDO=sudo
else
  printf '%s\n' 'Install sudo or run as root before continuing.' >&2
  exit 1
fi

install_prerequisites() {
  case "$PKG_TYPE" in
    deb)
      if [ "$DISTRO" = mint ]; then
        if ! $SUDO apt-get update; then
          if grep -RqsE '^[[:space:]]*(deb[[:space:]].*cdrom:|URIs:[[:space:]]*cdrom:)' /etc/apt/sources.list /etc/apt/sources.list.d 2>/dev/null; then
            printf '%s\n' 'APT update failed while a CD-ROM source is configured. Continuing with available package indexes; if prerequisite installation fails, disable the CD-ROM source in Software Sources and retry.' >&2
          else
            return 1
          fi
        fi
      else
        $SUDO apt-get update
      fi
      $SUDO apt-get install -y git ca-certificates curl nodejs npm build-essential
      ;;
    rpm)
      if ! $SUDO dnf --setopt=fastestmirror=0 --setopt=max_parallel_downloads=1 install -y git ca-certificates curl nodejs npm make gcc-c++ rpm-build; then
        printf '%s\n' 'Fedora package metadata lookup failed while installing prerequisites. Continuing only if the required tools are already present.' >&2
      fi
      ;;
    pacman)
      $SUDO pacman -Sy --noconfirm git ca-certificates curl nodejs npm base-devel
      ;;
    appimage)
      if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update
        $SUDO apt-get install -y git ca-certificates curl nodejs npm build-essential
      elif command -v dnf >/dev/null 2>&1; then
        if ! $SUDO dnf --setopt=fastestmirror=0 --setopt=max_parallel_downloads=1 install -y git ca-certificates curl nodejs npm make gcc-c++; then
          printf '%s\n' 'Fedora package metadata lookup failed while installing prerequisites. Continuing only if the required tools are already present.' >&2
        fi
      elif command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -Sy --noconfirm git ca-certificates curl nodejs npm base-devel
      fi
      ;;
  esac
}

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
  install_prerequisites
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
  printf '%s\n' 'Required build tools are still missing after the package manager attempt. Install git, nodejs, and npm manually, then retry.' >&2
  exit 1
fi

node_is_supported() {
  command -v node >/dev/null 2>&1 &&
    command -v npm >/dev/null 2>&1 &&
    node -e 'const [major, minor] = process.versions.node.split(".").map(Number); process.exit(major > 22 || (major === 22 && minor >= 12) ? 0 : 1)' >/dev/null 2>&1
}

if ! node_is_supported; then
  case "$(uname -m)" in
    x86_64) NODE_ARCH=x64 ;;
    aarch64|arm64) NODE_ARCH=arm64 ;;
    armv7l) NODE_ARCH=armv7l ;;
    *) printf '%s\n' "No Node.js 22 runtime is available for architecture $(uname -m)." >&2; exit 1 ;;
  esac
  if ! command -v curl >/dev/null 2>&1 || ! command -v sha256sum >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    printf '%s\n' 'curl, sha256sum, and tar are required to install the Node.js 22 runtime.' >&2
    exit 1
  fi

  NODE_TOOLCHAIN_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/toolchains
  mkdir -p "$NODE_TOOLCHAIN_DIR"
  NODE_DOWNLOAD_DIR=$(mktemp -d "$NODE_TOOLCHAIN_DIR/.powerbi-node.XXXXXX")
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
  rm -rf "$NODE_DOWNLOAD_DIR"
  NODE_DOWNLOAD_DIR=
  PATH=$NODE_RUNTIME_DIR/bin:$PATH
  export PATH
fi

if [ -z "$LOCAL_SOURCE_DIR" ]; then
  if [ -d "$REPOSITORY_DIR/.git" ]; then
    current_remote=$(git -C "$REPOSITORY_DIR" remote get-url origin 2>/dev/null || true)
    if [ -n "$current_remote" ] && [ "$current_remote" != "$REPOSITORY_URL" ]; then
      printf '%s\n' "Repository at $REPOSITORY_DIR points to $current_remote; choose another directory with ELECTRON_APPS_REPOSITORY_DIR." >&2
      exit 1
    fi
    STASHED_LOCAL_CHANGES=0
    if ! git -C "$REPOSITORY_DIR" diff --quiet || \
      ! git -C "$REPOSITORY_DIR" diff --cached --quiet || \
      [ -n "$(git -C "$REPOSITORY_DIR" ls-files --others --exclude-standard)" ]; then
      git -C "$REPOSITORY_DIR" stash push --include-untracked -m 'linux-desktop-apps installer update' >/dev/null
      STASHED_LOCAL_CHANGES=1
    fi
    if ! git -C "$REPOSITORY_DIR" pull --ff-only; then
      if [ "$STASHED_LOCAL_CHANGES" -eq 1 ]; then
        git -C "$REPOSITORY_DIR" stash pop >/dev/null || true
      fi
      printf '%s\n' "Could not update repository at $REPOSITORY_DIR." >&2
      exit 1
    fi
    if [ "$STASHED_LOCAL_CHANGES" -eq 1 ] && ! git -C "$REPOSITORY_DIR" stash pop; then
      printf '%s\n' "Repository updated, but local changes could not be restored at $REPOSITORY_DIR." >&2
      exit 1
    fi
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

if ! node_is_supported; then
  printf '%s\n' "Node.js 22.12 or newer and npm are required to build $DISPLAY_NAME." >&2
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

install_appimage_package() {
  _appimage_path=$1
  APPIMAGE_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/$DEB_PACKAGE
  APPIMAGE_INSTALL=$APPIMAGE_DIR/$DEB_PACKAGE.AppImage
  LAUNCHER_DIR=${XDG_BIN_HOME:-$HOME/.local/bin}
  LAUNCHER=$LAUNCHER_DIR/$DEB_PACKAGE
  mkdir -p "$APPIMAGE_DIR" "$LAUNCHER_DIR" "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
  cp "$_appimage_path" "$APPIMAGE_INSTALL"
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
Categories=Office;Network;DataVisualization;
StartupNotify=true
EOF
  chmod 644 "$DESKTOP_FILE"
  if command -v gio >/dev/null 2>&1; then
    gio set "$DESKTOP_FILE" metadata::trusted true 2>/dev/null || true
  fi
  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${XDG_DATA_HOME:-$HOME/.local/share}/applications" 2>/dev/null || true
  fi
}

if [ "$DISTRO" = kali ]; then
  npx electron-builder --linux AppImage
  APPIMAGE_PATH=$(find dist -maxdepth 1 -type f -name '*.AppImage' -print | sort | head -n 1)
  if [ -z "$APPIMAGE_PATH" ]; then
    printf '%s\n' "No AppImage was created for $DISPLAY_NAME." >&2
    exit 1
  fi
  install_appimage_package "$APPIMAGE_PATH"
  printf '%s\n' "$DISPLAY_NAME installed as an AppImage. Search for it in the application menu."
  exit 0
fi

if [ "$DISTRO" = ubuntu ] || [ "$DISTRO" = debian ] || [ "$DISTRO" = mint ]; then
  npx electron-builder --linux deb
  DEB_PATH=$(find dist -maxdepth 1 -type f -name '*.deb' -print | sort | head -n 1)
  if [ -z "$DEB_PATH" ]; then
    printf '%s\n' "No Debian package was created for $DISPLAY_NAME." >&2
    exit 1
  fi
  $SUDO apt-get install -y "$(CDPATH= cd -- "$LOCAL_SOURCE_DIR" && pwd)/$DEB_PATH" || {
    $SUDO dpkg -i "$(CDPATH= cd -- "$LOCAL_SOURCE_DIR" && pwd)/$DEB_PATH"
    $SUDO apt-get install -f -y
  }
  printf '%s\n' "$DISPLAY_NAME installed. Search for it in the application menu."
  exit 0
fi

if [ "$DISTRO" = fedora ]; then
  RPM_PATH=""
  if npx electron-builder --linux rpm 2>/dev/null; then
    RPM_PATH=$(find dist -maxdepth 1 -type f -name '*.rpm' -print | sort | head -n 1)
  fi

  if [ -n "$RPM_PATH" ] && [ -f "$RPM_PATH" ]; then
    if command -v dnf >/dev/null 2>&1; then
      $SUDO dnf install -y "$(CDPATH= cd -- "$LOCAL_SOURCE_DIR" && pwd)/$RPM_PATH"
    else
      $SUDO rpm -Uvh --replacepkgs "$(CDPATH= cd -- "$LOCAL_SOURCE_DIR" && pwd)/$RPM_PATH"
    fi
    printf '%s\n' "$DISPLAY_NAME installed on Fedora. Search for it in the application menu."
    exit 0
  fi

  printf '%s\n' "Building AppImage package for Fedora..."
  npx electron-builder --linux AppImage
  APPIMAGE_PATH=$(find dist -maxdepth 1 -type f -name '*.AppImage' -print | sort | head -n 1)
  if [ -z "$APPIMAGE_PATH" ]; then
    printf '%s\n' "No package could be created for $DISPLAY_NAME on Fedora." >&2
    exit 1
  fi
  install_appimage_package "$APPIMAGE_PATH"
  printf '%s\n' "$DISPLAY_NAME installed as an AppImage on Fedora. Search for it in the application menu."
  exit 0
fi

if [ "$DISTRO" = arch ]; then
  PACMAN_PATH=""
  if npx electron-builder --linux pacman 2>/dev/null; then
    PACMAN_PATH=$(find dist -maxdepth 1 -type f \( -name '*.pacman' -o -name '*.pkg.tar.*' \) -print | sort | head -n 1)
  fi

  if [ -n "$PACMAN_PATH" ] && [ -f "$PACMAN_PATH" ]; then
    $SUDO pacman -U --noconfirm "$(CDPATH= cd -- "$LOCAL_SOURCE_DIR" && pwd)/$PACMAN_PATH"
    printf '%s\n' "$DISPLAY_NAME installed on Arch Linux. Search for it in the application menu."
    exit 0
  fi

  printf '%s\n' "Building AppImage package for Arch Linux..."
  npx electron-builder --linux AppImage
  APPIMAGE_PATH=$(find dist -maxdepth 1 -type f -name '*.AppImage' -print | sort | head -n 1)
  if [ -z "$APPIMAGE_PATH" ]; then
    printf '%s\n' "No package could be created for $DISPLAY_NAME on Arch Linux." >&2
    exit 1
  fi
  install_appimage_package "$APPIMAGE_PATH"
  printf '%s\n' "$DISPLAY_NAME installed as an AppImage on Arch Linux. Search for it in the application menu."
  exit 0
fi

printf '%s\n' "Installation completed for $DISPLAY_NAME."