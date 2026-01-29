#!/usr/bin/env bash
# Hyprland workspace application startup script

# Wait for Hyprland to be fully initialized
sleep 2

# Workspace 1: Alacritty terminal
hyprctl dispatch workspace 1
alacritty &
sleep 2

# Workspace 2: Chrome with work profile
hyprctl dispatch workspace 3
google-chrome-stable --profile-directory=Default &
sleep 3

# Workspace 3: Chrome with personal profile
hyprctl dispatch workspace 4
google-chrome-stable --profile-directory="Profile 1" --new-window &
sleep 3

# Workspace 4: Discord
hyprctl dispatch workspace 2
discord &
sleep 3

# Workspace 9: Spotify
hyprctl dispatch workspace 9
spotify &
sleep 2

# Return to workspace 1
hyprctl dispatch workspace 1
