#!/usr/bin/env bash

# Toggle hypridle on/off for gaming sessions

if pgrep -x "hypridle" > /dev/null; then
    # hypridle is running, kill it
    pkill -x hypridle
    notify-send "Gaming Mode" "Hypridle disabled - screen won't sleep" -t 3000
else
    # hypridle is not running, start it
    hypridle &
    notify-send "Normal Mode" "Hypridle enabled - screen will sleep after 10min" -t 3000
fi

# Force waybar to refresh the status immediately
pkill -RTMIN+8 waybar
