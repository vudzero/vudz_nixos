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
        cp -r "$item" "$TARGET_HOME/"
    fi
done

# Disable dotglob
shopt -u dotglob

echo ""
echo "Configuration files deployed successfully!"
echo "You may need to reload your window manager or applications to see the changes."
