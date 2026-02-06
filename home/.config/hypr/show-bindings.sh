#!/usr/bin/env bash
set -euo pipefail

keybindings_path="$HOME/.config/hypr/keybindings.md"

if [ ! -f "$keybindings_path" ]; then
    if command -v notify-send &> /dev/null; then
        notify-send "Hyprland Bindings" "Keybindings file not found: $keybindings_path"
    fi
    exit 1
fi

bindings=$(awk '
function trim(s) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", s)
    return s
}

/^\|/ && NR > 4 {  # skip comment, empty, header, and separator lines
    split($0, parts, "|")
    binding = trim(parts[2])
    desc = trim(parts[3])
    bindings[++count] = binding
    descriptions[count] = desc
    if (length(binding) > max_len) max_len = length(binding)
}
END {
    for (i = 1; i <= count; i++) {
        printf "%-*s → %s\n", max_len, bindings[i], descriptions[i]
    }
}
' "$keybindings_path")

if [ -z "$bindings" ]; then
    if command -v notify-send &> /dev/null; then
        notify-send "Hyprland Bindings" "No bindings found in $config_path"
    fi
    exit 0
fi

if ! command -v walker &> /dev/null; then
    if command -v notify-send &> /dev/null; then
        notify-send "Hyprland Bindings" "walker not found on PATH"
    fi
    exit 1
fi

monitor_height=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .height')
menu_height=$((monitor_height * 20 / 100))

err_file=$(mktemp)
if ! selected=$(printf '%s\n' "$bindings" | walker --dmenu -p 'Keybindings' --width 800 --height "$menu_height" 2>"$err_file"); then
    if command -v notify-send &> /dev/null; then
        err_msg=$(head -n 1 "$err_file")
        if [ -n "$err_msg" ]; then
            notify-send "Hyprland Bindings" "walker error: $err_msg"
        else
            notify-send "Hyprland Bindings" "walker exited without output"
        fi
    fi
    rm -f "$err_file"
    exit 1
fi
rm -f "$err_file"

if [ -n "$selected" ] && command -v wl-copy &> /dev/null; then
    printf '%s' "$selected" | wl-copy
    if command -v notify-send &> /dev/null; then
        notify-send "Hyprland Bindings" "Copied selection to clipboard"
    fi
fi
