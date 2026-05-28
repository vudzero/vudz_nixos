#!/usr/bin/env bash
set -euo pipefail

if ! command -v hyprctl >/dev/null 2>&1; then
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Display Scale" "jq not found on PATH"
    fi
    exit 1
fi

if ! command -v rofi >/dev/null 2>&1; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Display Scale" "rofi not found on PATH"
    fi
    exit 1
fi

selected_scale=$(printf '%s\n' "1" "2" "2.5" | rofi -dmenu -p 'Monitor Scale')

if [ -z "${selected_scale}" ]; then
    exit 0
fi

focused_monitor=$(hyprctl monitors -j | jq -r 'map(select(.focused == true))[0].name // empty')

if [ -z "${focused_monitor}" ]; then
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Display Scale" "Could not detect focused monitor"
    fi
    exit 1
fi

hyprctl keyword monitor "${focused_monitor},highres,auto,${selected_scale}" >/dev/null

if command -v notify-send >/dev/null 2>&1; then
    notify-send "Display Scale" "Set ${focused_monitor} to ${selected_scale}x"
fi
