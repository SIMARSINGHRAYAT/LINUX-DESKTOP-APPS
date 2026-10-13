#!/bin/sh
set -eu
LOCAL_SCRIPT="$(dirname "$0")/../scripts/install-linux-app.sh"
if [ "${LINUX_DESKTOP_USE_LOCAL_INSTALLER:-0}" = 1 ] && [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" Azure microsoft-azure 'Microsoft Azure' microsoft-azure.png "$(CDPATH= cd -- "$(dirname "$0")" && pwd)"; fi
export ELECTRON_APPS_REPOSITORY_DIR="${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/linux-desktop-apps-azure}"
curl -fsSL https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/raw/refs/heads/main/csc-main/MICROSOFT-DESKTOP-APPS/scripts/install-linux-app.sh | sh -s -- Azure microsoft-azure 'Microsoft Azure' microsoft-azure.png
