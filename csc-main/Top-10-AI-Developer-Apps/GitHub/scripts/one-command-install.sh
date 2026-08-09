#!/bin/sh
set -eu

APP_ID='io.github.example.GitHubDesktop'
REPOSITORY_URL='https://github.com/FANCOINBOY/csc.git'
REPOSITORY_DIR="${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/csc}"
INSTALL_DIR="$REPOSITORY_DIR/Top-10-AI-Developer-Apps/GitHub"

printf '%s\n' 'GitHub Desktop for Linux - one-command installer'
printf '%s\n' 'This installs the unofficial wrapper from the project repository.'

if [ "$(uname -s)" != 'Linux' ]; then
  printf '%s\n' 'This installer supports Linux only.' >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  printf '%s\n' 'sudo is required to install Ubuntu prerequisites.' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'This bootstrap installer requires an Ubuntu/Debian system with apt-get.' >&2
  exit 1
fi

printf '%s\n' 'Installing system prerequisites (sudo may ask for your password)...'
sudo apt-get update
sudo apt-get install -y flatpak flatpak-builder git ca-certificates

if [ -d "$REPOSITORY_DIR/.git" ]; then
  printf '%s\n' "Updating $REPOSITORY_DIR..."
  git -C "$REPOSITORY_DIR" pull --ff-only
else
  if [ -e "$REPOSITORY_DIR" ]; then
    printf '%s\n' "$REPOSITORY_DIR exists but is not a Git checkout. Choose another directory with ELECTRON_APPS_REPOSITORY_DIR." >&2
    exit 1
  fi
  printf '%s\n' "Downloading project to $REPOSITORY_DIR..."
  mkdir -p "$(dirname "$REPOSITORY_DIR")"
  git clone "$REPOSITORY_URL" "$REPOSITORY_DIR"
fi

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub org.freedesktop.Sdk//25.08 org.freedesktop.Platform//25.08

printf '%s\n' 'Building and installing the Flatpak...'
cd "$INSTALL_DIR"
./install.sh

printf '%s\n' 'Launching GitHub Desktop...'
exec flatpak run "$APP_ID"