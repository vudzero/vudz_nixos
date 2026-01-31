#!/usr/bin/env bash

# Get all audio sinks with their status (keep asterisk to identify current device)
sinks_raw=$(wpctl status | awk '/Sinks:/,/Sources:/' | grep -E '[0-9]+\.' | sed 's/.*│//' | sed 's/^[[:space:]]*//' | grep -E '^(\*\s+)?[0-9]+\.')

# Check if we found any sinks
if [ -z "$sinks_raw" ]; then
    if command -v notify-send &> /dev/null; then
        notify-send "Audio Switcher" "No audio devices found"
    fi
    exit 1
fi

# Identify current device (marked with *) and others
current_sink=$(echo "$sinks_raw" | grep '^\*' | sed 's/^\*\s*//' | sed 's/\[vol:.*\]$//' | sed 's/[[:space:]]*$//')
other_sinks=$(echo "$sinks_raw" | grep -v '^\*' | sed 's/\[vol:.*\]$//' | sed 's/[[:space:]]*$//')

# Build walker list with current device at top (marked with ►)
if [ -n "$current_sink" ]; then
    walker_list=$(echo -e "► $current_sink\n$other_sinks")
else
    walker_list=$(echo "$other_sinks")
fi

# Show walker menu
selected=$(echo "$walker_list" | walker --dmenu)

# Exit if nothing selected
if [ -z "$selected" ]; then
    exit 0
fi

# Extract the sink ID from the selected line (first number before the dot, strip ► marker)
sink_id=$(echo "$selected" | sed 's/^► //' | grep -oE '^[0-9]+' | head -1)

# Set as default sink
wpctl set-default "$sink_id"

# Set volume to 24%
wpctl set-volume "$sink_id" 24%

# Get device name for notification (remove ► marker, ID number and dot)
device_name=$(echo "$selected" | sed 's/^► //' | sed 's/^[0-9]*\.\s*//' | sed 's/[[:space:]]*$//')

# Send notification (if notify-send is available)
if command -v notify-send &> /dev/null; then
    notify-send "Audio Switcher" "Switched to: $device_name\nVolume set to 24%"
fi
