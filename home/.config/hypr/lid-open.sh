#!/usr/bin/env bash
# When lid opens: enable laptop display and move workspaces back to it

# Enable laptop display
hyprctl keyword monitor "eDP-1, 2560x1600, 0x0, 1"

# Move all workspaces back to laptop display
for i in {1..9}; do
    hyprctl keyword workspace "$i, monitor:eDP-1"
done
