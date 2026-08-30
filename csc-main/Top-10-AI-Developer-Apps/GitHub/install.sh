#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"; if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Top-10-AI-Developer-Apps/GitHub io.github.simarsinghrayat.GitHubWeb 'GitHub' github-web github-web; fi
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/scripts/install-linux-app.sh | sh -s -- Top-10-AI-Developer-Apps/GitHub io.github.simarsinghrayat.GitHubWeb 'GitHub' github-web github-web