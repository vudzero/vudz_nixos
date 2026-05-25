#!/bin/bash
output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit 0
vol=$(echo "$output" | awk '{printf "%d", $2 * 100}')
if echo "$output" | grep -q "MUTED"; then
    echo "🔇 ${vol}%"
else
    echo "🔊 ${vol}%"
fi
