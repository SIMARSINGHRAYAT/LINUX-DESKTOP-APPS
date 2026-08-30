#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali uninstallation.
LOCAL_SCRIPT="$(dirname "$0")/../../scripts/uninstall-linux-app.sh"; if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" io.github.simarsinghrayat.GitHubWeb github-web; fi
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/scripts/uninstall-linux-app.sh | sh -s -- io.github.simarsinghrayat.GitHubWeb github-web
