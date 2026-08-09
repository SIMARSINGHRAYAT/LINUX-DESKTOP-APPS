#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  printf '%s\n' "Usage: $0 APP_ID" >&2
  exit 2
fi

APP_ID=$1
flatpak uninstall --user -y "$APP_ID" 2>/dev/null || true
flatpak uninstall --system -y "$APP_ID" 2>/dev/null || true
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/app/$APP_ID" "${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/exports"/share/applications/"$APP_ID".desktop
rm -rf "$HOME/.var/app/$APP_ID"