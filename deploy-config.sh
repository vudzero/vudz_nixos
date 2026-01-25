#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_CONFIG="$SCRIPT_DIR/.config"
TARGET_CONFIG="$HOME/.config"

echo "Deploying user configuration files..."
echo "Source: $SOURCE_CONFIG"
echo "Target: $TARGET_CONFIG"
echo ""

# Create ~/.config if it doesn't exist
mkdir -p "$TARGET_CONFIG"

# Copy all files and directories from .config to ~/.config
for item in "$SOURCE_CONFIG"/*; do
    if [ -e "$item" ]; then
        basename_item=$(basename "$item")
        echo "Copying $basename_item..."
        cp -r "$item" "$TARGET_CONFIG/"
    fi
done

echo ""
echo "Configuration files deployed successfully!"
echo "You may need to reload your window manager or applications to see the changes."
