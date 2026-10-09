#!/bin/sh
set -eu

LOCAL_SCRIPT="$(dirname "$0")/../../csc-main/MICROSOFT-DESKTOP-APPS/scripts/install-linux-app.sh"
if [ -f "$LOCAL_SCRIPT" ]; then
  exec "$LOCAL_SCRIPT" Qwen qwen-desktop Qwen '' "$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
fi

REPOSITORY_URL=${ELECTRON_APPS_REPOSITORY_URL:-https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS.git}
REPOSITORY_DIR=${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/linux-desktop-apps}

if [ -d "$REPOSITORY_DIR/.git" ]; then
  git -C "$REPOSITORY_DIR" pull --ff-only
elif [ -e "$REPOSITORY_DIR" ]; then
  printf '%s\n' "$REPOSITORY_DIR exists but is not a Git checkout." >&2
  exit 1
else
  mkdir -p "$(dirname "$REPOSITORY_DIR")"
  git clone "$REPOSITORY_URL" "$REPOSITORY_DIR"
fi

SHARED_SCRIPT=$REPOSITORY_DIR/csc-main/MICROSOFT-DESKTOP-APPS/scripts/install-linux-app.sh
QWEN_SOURCE=$REPOSITORY_DIR/ai/Qwen
if [ ! -f "$SHARED_SCRIPT" ] || [ ! -d "$QWEN_SOURCE" ]; then
  printf '%s\n' "Qwen source is missing from $REPOSITORY_DIR." >&2
  exit 1
fi
exec "$SHARED_SCRIPT" Qwen qwen-desktop Qwen '' "$QWEN_SOURCE"
