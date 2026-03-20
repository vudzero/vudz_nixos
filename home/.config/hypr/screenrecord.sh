#!/usr/bin/env bash
# Screen recorder script for Hyprland
# Records a selected area for 10 seconds

GEOM="$(slurp -w 0)"
if [ -z "$GEOM" ]; then
    exit 1
fi

OUTPUT="$HOME/Pictures/recording-$(date +%Y%m%d-%H%M%S).mp4"

# Start recording in background
wl-screenrec --geometry "$GEOM" -f "$OUTPUT" &
PID=$!

# Wait 10 seconds
sleep 10

# Gracefully stop the recording
if kill -0 $PID 2>/dev/null; then
    kill -TERM $PID 2>/dev/null
    # Wait up to 2 seconds for process to finish
    for i in {1..20}; do
        if ! kill -0 $PID 2>/dev/null; then
            break
        fi
        sleep 0.1
    done
    # Force kill if still running
    if kill -0 $PID 2>/dev/null; then
        kill -KILL $PID 2>/dev/null
    fi
fi

# Send notification
notify-send "Recording saved" "Saved to $OUTPUT"
