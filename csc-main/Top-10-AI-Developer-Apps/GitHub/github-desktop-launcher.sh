#!/bin/sh
# GitHub Desktop system launcher wrapper
# This script runs the GitHub Flatpak app with xvfb-run if needed

DISPLAY_ENV="${DISPLAY:-}"
WAYLAND_ENV="${WAYLAND_DISPLAY:-}"

# If we have a display, use Flatpak directly
if [ -n "$DISPLAY_ENV" ] || [ -n "$WAYLAND_ENV" ]; then
  exec flatpak run io.github.example.GitHubDesktop "$@"
fi

# No display available - try xvfb-run with proper DISPLAY passing
if command -v xvfb-run >/dev/null 2>&1; then
  echo "Starting GitHub Desktop in virtual display..."
  
  # Use xvfb-run to create a virtual display and pass it to Flatpak
  exec xvfb-run -a -s "-screen 0 1920x1080x24" bash -c \
    "flatpak run --env=DISPLAY=\$DISPLAY io.github.example.GitHubDesktop \"\$@\"" \
    -- "$@"
fi

# Fallback to direct Flatpak run
echo "Warning: No graphical display and xvfb-run not found. Install xvfb package for better compatibility."
exec flatpak run io.github.example.GitHubDesktop "$@"
