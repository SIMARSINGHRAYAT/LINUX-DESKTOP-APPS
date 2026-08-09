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
LOCAL_SOURCE_DIR=${5:-}
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
  $SUDO apt-get install -y git ca-certificates nodejs npm
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
  LOCAL_SOURCE_DIR=$REPOSITORY_DIR/csc-main/MICROSOFT-DESKTOP-APPS/$APP_DIRECTORY
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

LOGO_SOURCE=$REPOSITORY_DIR/csc-main/logo/$LOGO_FILE
if [ -n "${5:-}" ]; then
  LOGO_SOURCE=$(CDPATH= cd -- "$LOCAL_SOURCE_DIR/../../.." && pwd)/csc-main/logo/$LOGO_FILE
fi
if [ ! -f "$LOGO_SOURCE" ]; then
  printf '%s\n' "Provided logo not found: $LOGO_SOURCE" >&2
  exit 1
fi

ICON_DIR=$LOCAL_SOURCE_DIR/assets/icons
mkdir -p "$ICON_DIR"
cp "$LOGO_SOURCE" "$ICON_DIR/512.png"
if command -v convert >/dev/null 2>&1; then
  for size in 16 32 48 64 128 256; do
    convert "$LOGO_SOURCE" -resize "${size}x${size}" "$ICON_DIR/$size.png"
  done
fi

cd "$LOCAL_SOURCE_DIR"
npm install --no-audit --no-fund
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