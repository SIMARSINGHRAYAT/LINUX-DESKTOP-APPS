#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then
	exec "$LOCAL_SCRIPT" Streaming-Apps/Netflix io.github.example.NetflixDesktop 'Netflix desktop app'
fi
curl -fsSL https://raw.githubusercontent.com/FANCOINBOY/csc/main/scripts/install-linux-app.sh | sh -s -- Streaming-Apps/Netflix io.github.example.NetflixDesktop 'Netflix desktop app'
