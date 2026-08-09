#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
for chrome in google-chrome google-chrome-stable chromium chromium-browser; do
	if command -v "$chrome" >/dev/null 2>&1; then
		PRIMEVIDEO_PROFILE=${PRIMEVIDEO_PROFILE_DIR:-$HOME/.config/prime-video-desktop}
		mkdir -p "$PRIMEVIDEO_PROFILE"
		exec "$chrome" --app=https://www.primevideo.com/ --user-data-dir="$PRIMEVIDEO_PROFILE" --no-first-run --no-default-browser-check --disable-gpu
	fi
done

LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Streaming-Apps/PrimeVideo io.github.example.PrimeVideoDesktop 'Prime Video desktop app'; fi
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/scripts/install-linux-app.sh | sh -s -- Streaming-Apps/PrimeVideo io.github.example.PrimeVideoDesktop 'Prime Video desktop app'
