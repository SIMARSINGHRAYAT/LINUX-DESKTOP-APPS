#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
LOCAL_SCRIPT="$SCRIPT_DIR/../../../scripts/install-linux-app.sh"
REMOTE_SCRIPT='https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/scripts/install-linux-app.sh'

if [ -f "$LOCAL_SCRIPT" ]; then
  exec "$LOCAL_SCRIPT" Top-10-AI-Developer-Apps/GitHub io.github.example.GitHubDesktop 'GitHub'
fi
curl -fsSL "$REMOTE_SCRIPT" | sh -s -- Top-10-AI-Developer-Apps/GitHub io.github.example.GitHubDesktop 'GitHub'