#!/bin/bash
if systemctl --user is-active --quiet hypridle.service; then
    echo "💤"
else
    echo "🎮"
fi
