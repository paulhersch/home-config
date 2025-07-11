#!/usr/bin/env bash

waybar &
blueman-applet &
gammastep -P -O 5400 &
kanshi -c ~/.config/kanshi.conf &
