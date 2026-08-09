#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
LOCAL_CHROME_SCRIPT="$(dirname "$0")/../../scripts/install-chrome-streaming-app.sh"
if [ -f "$LOCAL_CHROME_SCRIPT" ]; then
	if "$LOCAL_CHROME_SCRIPT" io.github.example.CrunchyrollDesktop Crunchyroll https://www.crunchyroll.com/ crunchyroll-desktop Crunchyroll.png; then exit 0; fi
else
	if curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/scripts/install-chrome-streaming-app.sh | sh -s -- io.github.example.CrunchyrollDesktop Crunchyroll https://www.crunchyroll.com/ crunchyroll-desktop Crunchyroll.png; then exit 0; fi
fi

LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Streaming-Apps/Crunchyroll io.github.example.CrunchyrollDesktop 'Crunchyroll desktop app'; fi
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/scripts/install-linux-app.sh | sh -s -- Streaming-Apps/Crunchyroll io.github.example.CrunchyrollDesktop 'Crunchyroll desktop app'
