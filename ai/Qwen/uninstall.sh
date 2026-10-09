#!/bin/sh
set -eu
LOCAL_SCRIPT="$(dirname "$0")/../../csc-main/MICROSOFT-DESKTOP-APPS/scripts/uninstall-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then exec "$LOCAL_SCRIPT" qwen-desktop Qwen; fi
curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/MICROSOFT-DESKTOP-APPS/scripts/uninstall-linux-app.sh \
  | sh -s -- qwen-desktop Qwen
