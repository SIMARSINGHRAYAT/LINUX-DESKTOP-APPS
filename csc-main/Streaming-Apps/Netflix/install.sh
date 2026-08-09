#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
LOCAL_CHROME_SCRIPT="$(dirname "$0")/../../scripts/install-chrome-streaming-app.sh"
if [ -f "$LOCAL_CHROME_SCRIPT" ]; then
	if "$LOCAL_CHROME_SCRIPT" io.github.example.NetflixDesktop Netflix https://www.netflix.com/ netflix-desktop netflix.png; then exit 0; fi
else
	if curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/scripts/install-chrome-streaming-app.sh | sh -s -- io.github.example.NetflixDesktop Netflix https://www.netflix.com/ netflix-desktop netflix.png; then exit 0; fi
fi

LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then
	exec "$LOCAL_SCRIPT" Streaming-Apps/Netflix io.github.example.NetflixDesktop 'Netflix desktop app'
fi
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/scripts/install-linux-app.sh | sh -s -- Streaming-Apps/Netflix io.github.example.NetflixDesktop 'Netflix desktop app'
