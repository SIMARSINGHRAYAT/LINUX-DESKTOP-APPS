#!/bin/sh
set -eu

LOCAL_SCRIPT="$(dirname "$0")/../../csc-main/MICROSOFT-DESKTOP-APPS/scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then
  exec "$LOCAL_SCRIPT" Qwen qwen-desktop Qwen '' "$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
fi

curl -fsSL https://raw.githubusercontent.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS/main/csc-main/MICROSOFT-DESKTOP-APPS/scripts/install-linux-app.sh \
  | sh -s -- Qwen qwen-desktop Qwen ''
