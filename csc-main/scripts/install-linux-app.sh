#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
  printf '%s\n' "Usage: $0 APP_DIRECTORY APP_ID DISPLAY_NAME" >&2
  exit 2
fi

APP_DIRECTORY=$1
APP_ID=$2
DISPLAY_NAME=$3
REPOSITORY_URL=${ELECTRON_APPS_REPOSITORY_URL:-https://github.com/SIMARSINGHRAYAT/LINUX-DESKTOP-APPS.git}
REPOSITORY_DIR=${ELECTRON_APPS_REPOSITORY_DIR:-$HOME/electron-apps/linux-desktop-apps}
INSTALL_DIR=$REPOSITORY_DIR/csc-main/$APP_DIRECTORY

if [ "$(uname -s)" != Linux ]; then
  printf '%s\n' 'This installer supports Linux only.' >&2
  exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
  printf '%s\n' 'An apt-based Debian-family system is required (Ubuntu or Kali).' >&2
  exit 1
fi

needs_prerequisites=0
for tool in flatpak flatpak-builder git unzip xvfb-run; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    needs_prerequisites=1
    break
  fi
done

if [ "$needs_prerequisites" -eq 1 ]; then
  if [ "$(id -u)" -eq 0 ]; then
    SUDO=
  elif command -v sudo >/dev/null 2>&1; then
    SUDO=sudo
  else
    printf '%s\n' 'Run as root or install sudo before continuing.' >&2
    exit 1
  fi
  printf '%s\n' "Installing prerequisites for $DISPLAY_NAME..."
  $SUDO apt-get update
  $SUDO apt-get install -y flatpak flatpak-builder git ca-certificates unzip xvfb
fi

if [ -d "$REPOSITORY_DIR/.git" ]; then
  current_remote=$(git -C "$REPOSITORY_DIR" remote get-url origin 2>/dev/null || true)
  if [ -n "$current_remote" ] && [ "$current_remote" != "$REPOSITORY_URL" ]; then
    printf '%s\n' "Repository at $REPOSITORY_DIR points to $current_remote; choose another directory with ELECTRON_APPS_REPOSITORY_DIR." >&2
    exit 1
  fi
  git -C "$REPOSITORY_DIR" pull --ff-only
elif [ -e "$REPOSITORY_DIR" ]; then
  printf '%s\n' "$REPOSITORY_DIR exists but is not a Git checkout." >&2
  exit 1
else
  mkdir -p "$(dirname "$REPOSITORY_DIR")"
  git clone "$REPOSITORY_URL" "$REPOSITORY_DIR"
fi

if [ ! -d "$INSTALL_DIR" ] && [ -d "$REPOSITORY_DIR/$APP_DIRECTORY" ]; then
  INSTALL_DIR=$REPOSITORY_DIR/$APP_DIRECTORY
fi

if [ ! -d "$INSTALL_DIR" ]; then
  printf '%s\n' "Application directory not found: $INSTALL_DIR" >&2
  exit 1
fi

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install --user -y flathub org.freedesktop.Sdk//25.08 org.freedesktop.Platform//25.08

cd "$INSTALL_DIR"
flatpak-builder --user --install --force-clean --disable-rofiles-fuse build manifest.yaml

# Create a system-level launcher script with xvfb-run support
LAUNCHER_DIR="$HOME/.local/bin"
mkdir -p "$LAUNCHER_DIR"
LAUNCHER_SCRIPT="$LAUNCHER_DIR/github-desktop"

# Create the launcher with unquoted EOF to allow variable substitution
cat > "$LAUNCHER_SCRIPT" << EOF
#!/bin/sh
# GitHub Desktop launcher with xvfb-run support
DISPLAY_ENV="\${DISPLAY:-}"
WAYLAND_ENV="\${WAYLAND_DISPLAY:-}"

if [ -n "\$DISPLAY_ENV" ] || [ -n "\$WAYLAND_ENV" ]; then
  exec flatpak run io.github.example.GitHubDesktop "\$@"
fi

if command -v xvfb-run >/dev/null 2>&1; then
  # xvfb-run sets DISPLAY in the environment
  exec xvfb-run -a -s "-screen 0 1920x1080x24" bash -c 'flatpak run --env=DISPLAY=\$DISPLAY io.github.example.GitHubDesktop "\$@"' -- "\$@"
fi

exec flatpak run io.github.example.GitHubDesktop "\$@"
EOF

chmod 755 "$LAUNCHER_SCRIPT"
printf '%s\n' "✓ GitHub launcher installed to $LAUNCHER_SCRIPT"

exec "$LAUNCHER_SCRIPT"