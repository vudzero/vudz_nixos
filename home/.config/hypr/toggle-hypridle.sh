#!/usr/bin/env bash

# Toggle hypridle on/off for gaming sessions

if systemctl --user is-active --quiet hypridle.service; then
    systemctl --user stop hypridle.service
    notify-send "Gaming Mode" "Hypridle disabled - screen won't sleep" -t 3000
else
    systemctl --user start hypridle.service
    notify-send "Normal Mode" "Hypridle enabled - screen will sleep after 10min" -t 3000
fi
