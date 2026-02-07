#!/usr/bin/env bash

# Get all potential sinks from wpctl status
all_sinks=$(wpctl status | awk '
    /Audio/,/Video/ {
        if (/Sinks:/) { in_sinks=1; next }
        if (/Sources:/) { in_sinks=0 }
        if (in_sinks && /[0-9]+\./) print

        if (/Filters:/) { in_filters=1; next }
        if (/Streams:/) { in_filters=0 }
        if (in_filters && /\[Audio\/Sink\]/) print
    }
' | sed 's/.*│//' | sed 's/^[[:space:]]*//')

# Filter out internal/invalid sinks by checking media.class
sinks_raw=""
while IFS= read -r line; do
    [ -z "$line" ] && continue

    # Extract sink ID and check if it's marked as current (*)
    is_current=""
    if echo "$line" | grep -q '^\*'; then
        is_current="* "
    fi
    sink_id=$(echo "$line" | grep -oE '^(\*\s+)?[0-9]+' | grep -oE '[0-9]+')
    [ -z "$sink_id" ] && continue

    # Inspect the sink
    inspect_output=$(wpctl inspect "$sink_id" 2>/dev/null)

    # Check media.class - skip if Internal or not a valid sink
    media_class=$(echo "$inspect_output" | grep 'media.class' | head -1)
    if echo "$media_class" | grep -q "Internal"; then
        continue
    fi
    if ! echo "$media_class" | grep -q "Audio/Sink"; then
        continue
    fi

    # Get friendly name from node.description
    friendly_name=$(echo "$inspect_output" | grep 'node.description = ' | sed 's/.*node.description = "\(.*\)"/\1/')

    # If we got a friendly name, use it; otherwise use the original line text
    if [ -n "$friendly_name" ]; then
        formatted_line="${is_current}${sink_id}. ${friendly_name}"
    else
        # Fall back to original format
        formatted_line="$line"
    fi

    # Remove [vol:...] and [Audio/Sink] markers
    formatted_line=$(echo "$formatted_line" | sed 's/\[vol:.*\]$//' | sed 's/\[Audio\/Sink\]$//' | sed 's/[[:space:]]*$//')

    # Add to valid sinks
    if [ -z "$sinks_raw" ]; then
        sinks_raw="$formatted_line"
    else
        sinks_raw=$(printf "%s\n%s" "$sinks_raw" "$formatted_line")
    fi
done <<< "$all_sinks"

# Check if we found any sinks
if [ -z "$sinks_raw" ]; then
    if command -v notify-send &> /dev/null; then
        notify-send "Audio Switcher" "No audio devices found"
    fi
    exit 1
fi

# Identify current device (marked with *) and others
current_sink=$(echo "$sinks_raw" | grep '^\*' | sed 's/^\*\s*//' | sed 's/\[vol:.*\]$//' | sed 's/\[Audio\/Sink\]$//' | sed 's/[[:space:]]*$//')
other_sinks=$(echo "$sinks_raw" | grep -v '^\*' | sed 's/\[vol:.*\]$//' | sed 's/\[Audio\/Sink\]$//' | sed 's/[[:space:]]*$//')

# Build menu list with current device at top (marked with ►)
if [ -n "$current_sink" ]; then
    walker_list=$(echo -e "► $current_sink\n$other_sinks")
else
    walker_list=$(echo "$other_sinks")
fi

# Show walker menu
selected=$(echo "$walker_list" | rofi -dmenu -p 'Audio Device')

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
