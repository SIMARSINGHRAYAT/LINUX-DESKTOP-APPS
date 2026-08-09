#!/bin/sh
set -eu
LOCAL_SCRIPT="$(dirname "$0")/../scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Whiteboard microsoft-whiteboard 'Microsoft Whiteboard' Microsoft-whiteboard-94.png "$(CDPATH= cd -- "$(dirname "$0")" && pwd)"; fi
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/scripts/install-linux-app.sh | sh -s -- Whiteboard microsoft-whiteboard 'Microsoft Whiteboard' Microsoft-whiteboard-94.png