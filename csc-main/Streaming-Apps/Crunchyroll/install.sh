#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
for chrome in google-chrome google-chrome-stable chromium chromium-browser; do
	if command -v "$chrome" >/dev/null 2>&1; then
		CRUNCHYROLL_PROFILE=${CRUNCHYROLL_PROFILE_DIR:-$HOME/.config/crunchyroll-desktop}
		mkdir -p "$CRUNCHYROLL_PROFILE"
		exec "$chrome" --app=https://www.crunchyroll.com/ --user-data-dir="$CRUNCHYROLL_PROFILE" --no-first-run --no-default-browser-check --disable-gpu
	fi
done

LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Streaming-Apps/Crunchyroll io.github.example.CrunchyrollDesktop 'Crunchyroll desktop app'; fi
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/scripts/install-linux-app.sh | sh -s -- Streaming-Apps/Crunchyroll io.github.example.CrunchyrollDesktop 'Crunchyroll desktop app'
