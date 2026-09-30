#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_HOME="$SCRIPT_DIR/home"
TARGET_HOME="$HOME"

echo "Deploying user configuration files..."
echo "Source: $SOURCE_HOME"
echo "Target: $TARGET_HOME"
echo ""

# Enable dotglob to match hidden files
shopt -s dotglob

# Copy all files and directories from home to ~/
for item in "$SOURCE_HOME"/*; do
    if [ -e "$item" ]; then
        basename_item=$(basename "$item")
        echo "Copying $basename_item..."
        cp -rp "$item" "$TARGET_HOME/"
    fi
done

# Disable dotglob
shopt -u dotglob

echo ""
echo "Configuration files deployed successfully!"

# Import Kinova OpenVPN 3 profile when kinova.ovpn is present (gitignored).
if [ -f "$SCRIPT_DIR/kinova.ovpn" ]; then
    echo ""
    echo "Importing Kinova VPN profile..."
    "$SCRIPT_DIR/import-kinova-vpn.sh" "$SCRIPT_DIR/kinova.ovpn"
elif command -v openvpn3 >/dev/null 2>&1 && openvpn3 config-manage --config kinova-vpn --exists --quiet 2>/dev/null; then
    echo ""
    echo "Kinova VPN profile already imported (kinova-vpn)."
else
    echo ""
    echo "Kinova VPN profile not imported: copy kinova.ovpn into this repo and re-run,"
    echo "or run: ./import-kinova-vpn.sh /path/to/kinova.ovpn"
fi

# Smart reload Hyprland if running
echo ""
echo "Reloading Hyprland configuration (preserving monitor setup)..."
~/.config/hypr/smart-reload.sh
echo "Hyprland reloaded!"
