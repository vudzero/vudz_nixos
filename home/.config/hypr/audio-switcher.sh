#!/usr/bin/env bash

# Get all audio sinks (output devices) with their IDs and descriptions
sinks=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep -E '[0-9]+\.' | sed 's/.*│//' | sed 's/^[[:space:]]*\**//' | sed 's/^[[:space:]]*//' | grep -E '^[0-9]+\.')

# Check if we found any sinks
if [ -z "$sinks" ]; then
    if command -v notify-send &> /dev/null; then
        notify-send "Audio Switcher" "No audio devices found"
    fi
    exit 1
fi

# Format for walker: "ID. Device Name"
# Prepare walker list (already cleaned, just remove volume info)
walker_list=$(echo "$sinks" | sed 's/\[vol:.*\]$//' | sed 's/[[:space:]]*$//')

# Show walker menu
selected=$(echo "$walker_list" | walker --dmenu)

# Exit if nothing selected
if [ -z "$selected" ]; then
    exit 0
fi

# Extract the sink ID from the selected line (first number before the dot)
sink_id=$(echo "$selected" | grep -oE '^[0-9]+' | head -1)

# Set as default sink
wpctl set-default "$sink_id"

# Set volume to 24%
wpctl set-volume "$sink_id" 24%

# Get device name for notification (remove ID number and dot)
device_name=$(echo "$selected" | sed 's/^[0-9]*\.\s*//' | sed 's/[[:space:]]*$//')

# Send notification (if notify-send is available)
if command -v notify-send &> /dev/null; then
    notify-send "Audio Switcher" "Switched to: $device_name\nVolume set to 24%"
fi
