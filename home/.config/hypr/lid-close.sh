#!/usr/bin/env bash
# When lid closes: disable laptop display and move workspaces to external monitor

# Disable laptop display
hyprctl keyword monitor "eDP-1, disable"

# Move all workspaces to external monitor (DP-2)
for i in {1..9}; do
    hyprctl keyword workspace "$i, monitor:DP-2"
done
