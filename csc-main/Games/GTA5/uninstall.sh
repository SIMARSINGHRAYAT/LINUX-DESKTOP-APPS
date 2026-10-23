#!/bin/sh
set -eu

APP_ID=gta-5
DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
rm -f "$DATA_HOME/applications/$APP_ID.desktop"
rm -f "$DATA_HOME/icons/linux-desktop-apps/$APP_ID.svg"
rm -rf "$DATA_HOME/linux-desktop-apps/$APP_ID"

printf '%s\n' 'GTA 5 desktop launcher removed. Browser profile and game saves were left untouched.'
