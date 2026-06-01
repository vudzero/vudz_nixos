#!/usr/bin/env bash
# When lid opens: enable laptop display and move workspaces back to it

# Enable laptop display
hyprctl keyword monitor "eDP-1, 2560x1600, 0x0, 1"

# Move all workspaces back to laptop display
for i in {1..9}; do
    hyprctl dispatch moveworkspacetomonitor $i eDP-1
done

# Restart waybar to redraw it on the laptop display
pkill waybar && nohup waybar >/dev/null 2>&1 &
