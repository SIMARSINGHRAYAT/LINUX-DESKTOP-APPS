#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  printf '%s\n' "Usage: $0 DEB_PACKAGE DISPLAY_NAME" >&2
  exit 2
fi

DEB_PACKAGE=$1
DISPLAY_NAME=$2

if [ -r /etc/os-release ]; then
  . /etc/os-release
fi
RAW_DISTRO=${LINUX_DESKTOP_DISTRO:-${ID:-}}
RAW_DISTRO=$(echo "$RAW_DISTRO" | tr '[:upper:]' '[:lower:]')

case "$RAW_DISTRO" in
  ubuntu|debian|mint|linuxmint)
    DISTRO="deb"
    ;;
  kali)
    DISTRO="kali"
    ;;
  fedora)
    DISTRO="fedora"
    ;;
  arch|archlinux|manjaro|endeavouros)
    DISTRO="arch"
    ;;
  *)
    if command -v apt-get >/dev/null 2>&1; then
      DISTRO="deb"
    elif command -v dnf >/dev/null 2>&1; then
      DISTRO="fedora"
    elif command -v pacman >/dev/null 2>&1; then
      DISTRO="arch"
    else
      DISTRO="appimage"
    fi
    ;;
esac

if [ "$(id -u)" -eq 0 ]; then
  SUDO=
elif command -v sudo >/dev/null 2>&1; then
  SUDO=sudo
else
  SUDO=
fi

rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/applications/$DEB_PACKAGE.desktop"
rm -f "${XDG_BIN_HOME:-$HOME/.local/bin}/$DEB_PACKAGE"
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/linux-desktop-apps/$DEB_PACKAGE"

case "$DISTRO" in
  deb)
    if [ -n "$SUDO" ] || [ "$(id -u)" -eq 0 ]; then
      $SUDO apt-get remove -y "$DEB_PACKAGE" 2>/dev/null || true
    fi
    ;;
  fedora)
    if [ -n "$SUDO" ] || [ "$(id -u)" -eq 0 ]; then
      if command -v dnf >/dev/null 2>&1; then
        $SUDO dnf remove -y "$DEB_PACKAGE" 2>/dev/null || true
      elif command -v rpm >/dev/null 2>&1; then
        $SUDO rpm -e "$DEB_PACKAGE" 2>/dev/null || true
      fi
    fi
    ;;
  arch)
    if [ -n "$SUDO" ] || [ "$(id -u)" -eq 0 ]; then
      if command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -R --noconfirm "$DEB_PACKAGE" 2>/dev/null || true
      fi
    fi
    ;;
esac

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "${XDG_DATA_HOME:-$HOME/.local/share}/applications" 2>/dev/null || true
fi

printf '%s\n' "$DISPLAY_NAME uninstalled."