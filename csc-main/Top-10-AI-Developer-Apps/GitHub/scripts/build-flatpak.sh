#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
command -v flatpak-builder >/dev/null 2>&1 || { echo "flatpak-builder is required. Install it with: sudo apt install flatpak-builder" >&2; exit 1; }
flatpak-builder --user --force-clean --disable-rofiles-fuse build manifest.yaml