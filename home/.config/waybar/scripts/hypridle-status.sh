#!/usr/bin/env bash

# Check if hypridle is running and output status for waybar

if pgrep -x "hypridle" > /dev/null; then
    # hypridle is running - normal mode
    echo '{"text": "💤", "tooltip": "Hypridle enabled - Normal mode", "class": "enabled"}'
else
    # hypridle is not running - gaming mode
    echo '{"text": "🎮", "tooltip": "Hypridle disabled - Gaming mode", "class": "disabled"}'
fi
