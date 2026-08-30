#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf '%s\n' "Usage: $0 APP_ID [EXECUTABLE_NAME]" >&2
  exit 2
fi

APP_ID=$1
EXECUTABLE_NAME=${2:-}
flatpak uninstall --user -y "$APP_ID" 2>/dev/null || true
flatpak uninstall --system -y "$APP_ID" 2>/dev/null || true
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/app/$APP_ID" "${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/exports"/share/applications/"$APP_ID".desktop
rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/applications/$APP_ID.desktop" "${XDG_DATA_HOME:-$HOME/.local/share}/icons/linux-desktop-apps/$APP_ID.png"
if [ -n "$EXECUTABLE_NAME" ]; then
  rm -f "$HOME/.local/bin/$EXECUTABLE_NAME"
fi
rm -rf "$HOME/.var/app/$APP_ID"