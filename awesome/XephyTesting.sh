Xephyr :1 -ac -br -noreset -screen 1280x720 &
DISPLAY=:1.0 awesome -c ~/.config/awesome/rc.lua
