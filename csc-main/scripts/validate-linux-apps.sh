#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
failed=0

for category_dir in "$ROOT"/Top-10-AI-Developer-Apps "$ROOT"/Streaming-Apps; do
  [ -d "$category_dir" ] || continue
  for app_dir in "$category_dir"/*; do
    [ -d "$app_dir" ] || continue
    [ -f "$app_dir/package.json" ] || continue

    app_name=$(basename "$app_dir")
    for script in "$app_dir"/install.sh "$app_dir"/uninstall.sh "$app_dir"/scripts/*.sh; do
      [ -f "$script" ] || continue
      if ! sh -n "$script"; then
        printf '%s\n' "Invalid shell syntax: $script" >&2
        failed=1
      fi
    done

    if ! node --check "$app_dir/src/main.js" || ! node --check "$app_dir/src/preload.js"; then
      printf '%s\n' "Invalid JavaScript: $app_name" >&2
      failed=1
    fi

    if grep -q 'sudo apt-get\|--no-sandbox' "$app_dir/install.sh" 2>/dev/null; then
      printf '%s\n' "App wrapper contains unmanaged bootstrap behavior: $app_name" >&2
      failed=1
    fi
  done
done

for app_dir in "$ROOT/MICROSOFT-DESKTOP-APPS"/*; do
  [ -d "$app_dir" ] || continue
  [ -f "$app_dir/package.json" ] || continue

  app_name=$(basename "$app_dir")
  for script in "$app_dir"/install.sh "$app_dir"/uninstall.sh; do
    [ -f "$script" ] || continue
    if ! sh -n "$script"; then
      printf '%s\n' "Invalid shell syntax: $script" >&2
      failed=1
    fi
  done

  if ! node --check "$app_dir/main.js" || ! node --check "$app_dir/preload.js"; then
    printf '%s\n' "Invalid JavaScript: Microsoft $app_name" >&2
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  exit 1
fi
printf '%s\n' 'All Linux desktop app entry points passed validation.'