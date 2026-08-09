#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"; if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Top-10-AI-Developer-Apps/GoogleColab io.github.example.GoogleColabDesktop 'Google Colab desktop app'; fi
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/scripts/install-linux-app.sh | sh -s -- Top-10-AI-Developer-Apps/GoogleColab io.github.example.GoogleColabDesktop 'Google Colab desktop app'
