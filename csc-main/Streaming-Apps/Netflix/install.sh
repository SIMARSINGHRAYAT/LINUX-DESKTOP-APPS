#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
for chrome in google-chrome google-chrome-stable chromium chromium-browser; do

	if command -v "$chrome" >/dev/null 2>&1; then
		NETFLIX_PROFILE=${NETFLIX_PROFILE_DIR:-$HOME/.config/netflix-desktop}
		mkdir -p "$NETFLIX_PROFILE"
		exec "$chrome" --app=https://www.netflix.com/ --user-data-dir="$NETFLIX_PROFILE" --no-first-run --no-default-browser-check
	fi
done

LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then
	exec "$LOCAL_SCRIPT" Streaming-Apps/Netflix io.github.example.NetflixDesktop 'Netflix desktop app'
fi
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/scripts/install-linux-app.sh | sh -s -- Streaming-Apps/Netflix io.github.example.NetflixDesktop 'Netflix desktop app'
