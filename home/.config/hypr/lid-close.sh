#!/usr/bin/env bash
# When lid closes: disable laptop display and move workspaces to external monitor

# Disable laptop display
hyprctl keyword monitor "eDP-1, disable"

# Find the first active external monitor (not eDP-1)
EXTERNAL_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.name != "eDP-1") | .name' | head -n 1)

if [ -n "$EXTERNAL_MONITOR" ]; then
    # Move all workspaces to the external monitor
    for i in {1..9}; do
        hyprctl dispatch moveworkspacetomonitor $i "$EXTERNAL_MONITOR"
    done
fi

# Restart waybar to redraw it on the external monitor
pkill waybar && nohup waybar >/dev/null 2>&1 &
