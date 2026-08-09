#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Streaming-Apps/JioHotstar io.github.example.JioHotstarDesktop 'JioHotstar desktop app'; fi
curl -fsSL https://raw.githubusercontent.com/FANCOINBOY/csc/main/scripts/install-linux-app.sh | sh -s -- Streaming-Apps/JioHotstar io.github.example.JioHotstarDesktop 'JioHotstar desktop app'
