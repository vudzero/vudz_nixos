#!/bin/bash
if pgrep -x "hypridle" > /dev/null; then
    echo "💤"
else
    echo "🎮"
fi
