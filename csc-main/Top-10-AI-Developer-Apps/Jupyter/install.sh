#!/bin/sh
set -eu
# Supports local checkouts and curl-piped Ubuntu/Kali installation.
LOCAL_SCRIPT="$(dirname "$0")/../../scripts/install-linux-app.sh"
REMOTE_SCRIPT='https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/scripts/install-linux-app.sh'
if [ -f "$LOCAL_SCRIPT" ]; then
	exec "$LOCAL_SCRIPT" Top-10-AI-Developer-Apps/Jupyter io.github.example.JupyterDesktop 'Jupyter desktop app'
fi
curl -fsSL "$REMOTE_SCRIPT" | sh -s -- Top-10-AI-Developer-Apps/Jupyter io.github.example.JupyterDesktop 'Jupyter desktop app'
