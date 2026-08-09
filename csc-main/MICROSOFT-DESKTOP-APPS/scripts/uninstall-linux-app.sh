#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  printf '%s\n' "Usage: $0 DEB_PACKAGE DISPLAY_NAME" >&2
  exit 2
fi

DEB_PACKAGE=$1
DISPLAY_NAME=$2
if ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'An apt-based Debian-family system is required (Ubuntu, Debian, or Kali).' >&2
  exit 1
fi
if [ "$(id -u)" -eq 0 ]; then SUDO=; elif command -v sudo >/dev/null 2>&1; then SUDO=sudo; else
  printf '%s\n' 'Run as root or install sudo to uninstall the desktop package.' >&2
  exit 1
fi
$SUDO apt-get remove -y "$DEB_PACKAGE" 2>/dev/null || true
printf '%s\n' "$DISPLAY_NAME uninstalled."