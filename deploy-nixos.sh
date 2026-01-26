#!/usr/bin/env bash

set -e

echo "Copying configuration files to /etc/nixos/..."
sudo cp configuration.nix /etc/nixos/configuration.nix

# Note: hardware-configuration.nix is NOT copied - each machine generates its own
if [ ! -f /etc/nixos/hardware-configuration.nix ]; then
    echo "WARNING: /etc/nixos/hardware-configuration.nix does not exist!"
    echo "Generate it with: sudo nixos-generate-config"
    exit 1
fi

echo "Deploying NixOS configuration..."
# Always enable experimental features to ensure flakes work
# This is safe to use even if flakes are already enabled system-wide
sudo nixos-rebuild switch --option experimental-features "nix-command flakes"

echo "Deployment complete!"
