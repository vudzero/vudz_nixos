#!/usr/bin/env bash
# Hyprland workspace application startup script

# Configuration
STARTUP_DELAY=1

# Wait for Hyprland to be fully initialized
sleep $STARTUP_DELAY

# Helper function to get Chrome profile directory by custom name
get_chrome_profile() {
    local profile_name="$1"
    local chrome_state="$HOME/.config/google-chrome/Local State"
    jq -r --arg name "$profile_name" \
        '.profile.info_cache | to_entries[] | select(.value.name == $name) | .key' \
        "$chrome_state" 2>/dev/null
}

# Workspace 1: Alacritty terminal
hyprctl dispatch workspace 1
alacritty &
sleep $STARTUP_DELAY

# Workspace 2: Chrome with work profile (Kinova)
WORK_PROFILE=$(get_chrome_profile "Kinova")
if [ -n "$WORK_PROFILE" ]; then
    hyprctl dispatch workspace 3
    google-chrome-stable --profile-directory="$WORK_PROFILE" &
    sleep $STARTUP_DELAY
fi

# Workspace 3: Chrome with personal profile
PERSONAL_PROFILE=$(get_chrome_profile "Personal")
if [ -n "$PERSONAL_PROFILE" ]; then
    hyprctl dispatch workspace 4
    google-chrome-stable --profile-directory="$PERSONAL_PROFILE" &
    sleep $STARTUP_DELAY
fi

# Workspace 4: Discord
hyprctl dispatch workspace 2
discord &
sleep $STARTUP_DELAY

# Workspace 9: Spotify
hyprctl dispatch workspace 9
spotify &
sleep $STARTUP_DELAY

# Return to workspace 1
hyprctl dispatch workspace 1
