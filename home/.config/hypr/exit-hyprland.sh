#!/usr/bin/env bash
# Gracefully close all windows before exiting Hyprland

# Get all window addresses and close them
hyprctl clients -j | jq -r '.[].address' | while read -r addr; do
    hyprctl dispatch closewindow "address:$addr"
done

# Wait a moment for windows to process close requests
sleep 0.5

# Exit Hyprland
hyprctl dispatch exit
