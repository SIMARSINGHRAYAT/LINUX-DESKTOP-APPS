#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali uninstallation.
LOCAL_SCRIPT="$(dirname "$0")/../../scripts/uninstall-linux-app.sh"; if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" io.github.example.KaggleDesktop; fi
curl -fsSL https://raw.githubusercontent.com/FANCOINBOY/csc/main/scripts/uninstall-linux-app.sh | sh -s -- io.github.example.KaggleDesktop
