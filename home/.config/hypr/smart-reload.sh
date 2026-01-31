#!/usr/bin/env bash
# Smart reload that preserves monitor setup

# Reload Hyprland config
hyprctl reload

# Check if laptop display is disabled (lid closed)
if ! hyprctl monitors | grep -q "eDP-1"; then

    # Lid is closed, reassign workspaces to external monitor
    for i in {0..9}; do
        hyprctl dispatch moveworkspacetomonitor $1 DP-2
    done
fi
