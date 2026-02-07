#!/usr/bin/env bash
# Hyprland workspace application startup script with reliable window detection

# Configuration
POLL_INTERVAL=0.1        # Check every 100ms
DEFAULT_TIMEOUT=10       # 10 seconds per app
LOG_FAILURES=true        # Log to stderr
NOTIFY_FAILURES=true     # Show desktop notifications

# Success/failure tracking
SUCCESS_COUNT=0
FAILURE_COUNT=0

# Wait for Hyprland to be fully initialized
sleep 1

# Helper function to get Chrome profile directory by custom name
get_chrome_profile() {
    local profile_name="$1"
    local chrome_state="$HOME/.config/google-chrome/Local State"
    jq -r --arg name "$profile_name" \
        '.profile.info_cache | to_entries[] | select(.value.name == $name) | .key' \
        "$chrome_state" 2>/dev/null
}

# Helper function to get all window addresses for a specific class
get_window_addresses() {
    local window_class="$1"
    hyprctl clients -j | jq -r ".[] | select(.class == \"$window_class\") | .address"
}

# Helper function to wait for a new window of a specific class to appear
wait_for_new_window() {
    local window_class="$1"
    local timeout="${2:-$DEFAULT_TIMEOUT}"

    # Get baseline window addresses
    local baseline_addresses=$(get_window_addresses "$window_class")

    # Calculate max iterations (10 per second with POLL_INTERVAL=0.1)
    local max_iterations=$((timeout * 10))
    local iterations=0

    # Poll until a new window appears or timeout
    while [ $iterations -lt $max_iterations ]; do
        sleep "$POLL_INTERVAL"
        ((iterations++))

        # Get current window addresses
        local current_addresses=$(get_window_addresses "$window_class")

        # Find new addresses (present in current but not in baseline)
        local new_address=$(comm -13 <(echo "$baseline_addresses" | sort) <(echo "$current_addresses" | sort) | head -n1)

        if [ -n "$new_address" ]; then
            echo "$new_address"
            return 0  # Success
        fi
    done

    return 1  # Timeout
}

# Helper function to launch an app and move it to a workspace
launch_app_and_move() {
    local workspace_id="$1"
    local app_command="$2"
    local app_name="$3"
    local window_class="$4"

    # Launch app in background
    $app_command &
    local pid=$!

    # Wait for new window to appear and get its address
    local new_address=$(wait_for_new_window "$window_class")

    if [ -n "$new_address" ]; then
        # Move window to target workspace using its address
        hyprctl dispatch movetoworkspacesilent "$workspace_id,address:$new_address" >/dev/null
        return 0  # Success
    else
        # Handle failure
        if [ "$LOG_FAILURES" = true ]; then
            echo "ERROR: $app_name (PID $pid) failed to create a window" >&2
        fi
        if [ "$NOTIFY_FAILURES" = true ]; then
            notify-send -u critical "Startup Failed" "$app_name did not create a window"
        fi
        return 1  # Failure
    fi
}

# Helper function to launch Chrome with a specific profile and move it to a workspace
launch_chrome_profile() {
    local workspace_id="$1"
    local profile_name="$2"
    local profile_directory="$3"

    # Launch Chrome with profile in background
    google-chrome-stable --profile-directory="$profile_directory" &
    local pid=$!

    # Wait for new window to appear and get its address
    local new_address=$(wait_for_new_window "google-chrome")

    if [ -n "$new_address" ]; then
        # Move window to target workspace using its address
        hyprctl dispatch movetoworkspacesilent "$workspace_id,address:$new_address" >/dev/null
        return 0  # Success
    else
        # Handle failure
        if [ "$LOG_FAILURES" = true ]; then
            echo "ERROR: Chrome ($profile_name, PID $pid) failed to create a window" >&2
        fi
        if [ "$NOTIFY_FAILURES" = true ]; then
            notify-send -u critical "Startup Failed" "Chrome ($profile_name) did not create a window"
        fi
        return 1  # Failure
    fi
}

# Workspace 1: Alacritty terminal
if launch_app_and_move 1 "alacritty" "Alacritty" "Alacritty"; then
    ((SUCCESS_COUNT++))
else
    ((FAILURE_COUNT++))
fi

# Workspace 3: Chrome with work profile (Kinova)
WORK_PROFILE=$(get_chrome_profile "Kinova")
if [ -n "$WORK_PROFILE" ]; then
    if launch_chrome_profile 3 "Kinova" "$WORK_PROFILE"; then
        ((SUCCESS_COUNT++))
    else
        ((FAILURE_COUNT++))
    fi
fi

# Workspace 4: Chrome with personal profile
PERSONAL_PROFILE=$(get_chrome_profile "Personal")
if [ -n "$PERSONAL_PROFILE" ]; then
    if launch_chrome_profile 4 "Personal" "$PERSONAL_PROFILE"; then
        ((SUCCESS_COUNT++))
    else
        ((FAILURE_COUNT++))
    fi
fi

# Workspace 2: Discord
# Discord needs extra time to fully initialize its window
discord &
sleep 1.5  # Give Discord time to start up
new_discord_addr=$(wait_for_new_window "discord")
if [ -n "$new_discord_addr" ]; then
    sleep 0.5  # Extra delay before moving to ensure window is fully initialized
    hyprctl dispatch movetoworkspacesilent "2,address:$new_discord_addr" >/dev/null
    ((SUCCESS_COUNT++))
else
    if [ "$LOG_FAILURES" = true ]; then
        echo "ERROR: Discord failed to create a window" >&2
    fi
    if [ "$NOTIFY_FAILURES" = true ]; then
        notify-send -u critical "Startup Failed" "Discord did not create a window"
    fi
    ((FAILURE_COUNT++))
fi

# Workspace 2: Google Chat web app
if launch_app_and_move 2 "google-chrome --app=https://chat.google.com --profile-directory=\"Default\"" "Google Chat" "chrome-chat.google.com__-Default"; then
    ((SUCCESS_COUNT++))
else
    ((FAILURE_COUNT++))
fi

# Workspace 9: Spotify
if launch_app_and_move 9 "spotify" "Spotify" "spotify"; then
    ((SUCCESS_COUNT++))
else
    ((FAILURE_COUNT++))
fi

# Display summary notification if any failures occurred
if [ "$FAILURE_COUNT" -gt 0 ]; then
    notify-send -u critical "Startup Summary" "$SUCCESS_COUNT succeeded, $FAILURE_COUNT failed"
fi

# Return to workspace 1
hyprctl dispatch workspace 1
