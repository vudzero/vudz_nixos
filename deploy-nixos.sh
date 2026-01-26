#!/usr/bin/env bash

set -e

echo "Copying configuration files to /etc/nixos/..."
sudo cp configuration.nix /etc/nixos/configuration.nix
sudo cp hardware-configuration.nix /etc/nixos/hardware-configuration.nix

echo "Deploying NixOS configuration..."
# Always use --extra-experimental-features to ensure flakes work
# This is safe to use even if flakes are already enabled system-wide
sudo nixos-rebuild switch --extra-experimental-features "nix-command flakes"

echo "Deployment complete!"
