#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
  printf '%s\n' "Usage: $0 APP_DIRECTORY APP_ID DISPLAY_NAME" >&2
  exit 2
fi

APP_DIRECTORY=$1
APP_ID=$2
DISPLAY_NAME=$3
REPOSITORY_URL=${ELECTRON_APPS_REPOSITORY_URL:-https://github.com/FANCOINBOY/csc.git}
REPOSITORY_DIR=${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/csc}
INSTALL_DIR=$REPOSITORY_DIR/$APP_DIRECTORY

if [ "$(uname -s)" != Linux ]; then
  printf '%s\n' 'This installer supports Linux only.' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'An apt-based Debian-family system is required (Ubuntu or Kali).' >&2
  exit 1
fi

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
$SUDO apt-get install -y flatpak flatpak-builder git ca-certificates unzip

if [ -d "$REPOSITORY_DIR/.git" ]; then
  git -C "$REPOSITORY_DIR" pull --ff-only
elif [ -e "$REPOSITORY_DIR" ]; then
  printf '%s\n' "$REPOSITORY_DIR exists but is not a Git checkout." >&2
  exit 1
else
  mkdir -p "$(dirname "$REPOSITORY_DIR")"
  git clone "$REPOSITORY_URL" "$REPOSITORY_DIR"
fi

if [ ! -d "$INSTALL_DIR" ]; then
  printf '%s\n' "Application directory not found: $INSTALL_DIR" >&2
  exit 1
fi

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub org.freedesktop.Sdk//25.08 org.freedesktop.Platform//25.08

cd "$INSTALL_DIR"
flatpak-builder --user --install --force-clean --disable-rofiles-fuse build manifest.yaml
exec flatpak run "$APP_ID"