#!/usr/bin/env bash

set -e

# Detect machine name or use argument
MACHINE="${1:-}"

if [ -z "$MACHINE" ]; then
    # Auto-detect based on hostname
    CURRENT_HOSTNAME=$(hostname)

    if [ "$CURRENT_HOSTNAME" = "desktop" ] || [ "$CURRENT_HOSTNAME" = "laptop" ] || [ "$CURRENT_HOSTNAME" = "framework" ]; then
        MACHINE="$CURRENT_HOSTNAME"
        echo "Auto-detected machine: $MACHINE"
    else
        echo "Usage: $0 <machine>"
        echo ""
        echo "Available machines:"
        echo "  - desktop (with NVIDIA)"
        echo "  - framework"
        echo "  - laptop (with power management)"
        echo ""
        echo "Or set your hostname to 'desktop', 'laptop', or 'framework' for auto-detection."
        exit 1
    fi
fi

# Validate machine name
if [ ! -d "machines/$MACHINE" ]; then
    echo "Error: Machine '$MACHINE' not found in machines/ directory"
    exit 1
fi

MACHINE_DIR="machines/$MACHINE"

echo "Deploying configuration for: $MACHINE"
echo ""

# Check if hardware-configuration.nix exists in the repo
if [ ! -f "$MACHINE_DIR/hardware-configuration.nix" ]; then
    echo "Hardware configuration not found in $MACHINE_DIR/"

    # Check if it exists in /etc/nixos/
    if [ -f /etc/nixos/hardware-configuration.nix ]; then
        echo "Copying hardware-configuration.nix from /etc/nixos/ to $MACHINE_DIR/"
        cp /etc/nixos/hardware-configuration.nix "$MACHINE_DIR/hardware-configuration.nix"
        echo "Note: hardware-configuration.nix is not tracked in git (machine-specific)"
    else
        echo "ERROR: /etc/nixos/hardware-configuration.nix does not exist!"
        echo "Generate it with: sudo nixos-generate-config"
        exit 1
    fi
fi

echo "Deploying NixOS configuration with flake..."
sudo nixos-rebuild switch --flake ".#$MACHINE"

echo ""
echo "Deployment complete!"
echo ""
echo "Next steps:"
echo "  - Commit your changes: git add . && git commit -m 'Update configuration'"
echo "  - On a new machine, run: ./deploy-nixos.sh <machine-name>"
