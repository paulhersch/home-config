#!/usr/bin/env bash

SWWW_DAEMON_PID=$(pgrep "swww-daemon")
# first instance will stay alive if called again from a wm restart
if [[ -z "$SWWW_DAEMON_PID" ]]; then
    swww-daemon &
fi

# set random wallpaper from a selected subset
SELECTION=("$HOME/Bilder/Hintergrundbilder/cherry_blossom_closeup.jpg")
SELECTION+=("$HOME/Bilder/Hintergrundbilder/field.jpg")
SELECTION+=("$HOME/Bilder/Hintergrundbilder/pelicans.jpg")

RANDOM_INDEX=$(( RANDOM % ${#SELECTION[@]} ))
swww img -t fade --transition-duration=0.5 "${SELECTION[$RANDOM_INDEX]}"
