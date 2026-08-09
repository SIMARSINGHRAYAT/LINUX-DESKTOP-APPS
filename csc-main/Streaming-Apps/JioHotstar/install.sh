#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
LOCAL_CHROME_SCRIPT="$(dirname "$0")/../../scripts/install-chrome-streaming-app.sh"
if [ -f "$LOCAL_CHROME_SCRIPT" ]; then
	if "$LOCAL_CHROME_SCRIPT" io.github.example.JioHotstarDesktop JioHotstar https://www.hotstar.com/ jiohotstar-desktop jiohotstar.png; then exit 0; fi
else
	if curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/scripts/install-chrome-streaming-app.sh | sh -s -- io.github.example.JioHotstarDesktop JioHotstar https://www.hotstar.com/ jiohotstar-desktop jiohotstar.png; then exit 0; fi
fi

LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Streaming-Apps/JioHotstar io.github.example.JioHotstarDesktop 'JioHotstar desktop app'; fi
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/scripts/install-linux-app.sh | sh -s -- Streaming-Apps/JioHotstar io.github.example.JioHotstarDesktop 'JioHotstar desktop app'
