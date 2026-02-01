#!/usr/bin/env bash
# Smart reload that preserves monitor setup

# Check physical lid state
LID_STATE=$(cat /proc/acpi/button/lid/*/state 2>/dev/null | awk '{print $NF}')

if [ "$LID_STATE" = "closed" ]; then
    # Lid is closed, reassign workspaces to external monitor
    echo "Lid is closed, moving workspaces to external monitor..."
    for i in {0..9}; do
        hyprctl dispatch moveworkspacetomonitor $i DP-2
    done
else
    echo "Lid is open, skipping workspace migration"
fi
