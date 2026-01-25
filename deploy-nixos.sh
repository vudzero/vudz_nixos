#!/usr/bin/env bash

set -e

echo "Copying configuration files to /etc/nixos/..."
sudo cp configuration.nix /etc/nixos/configuration.nix
sudo cp hardware-configuration.nix /etc/nixos/hardware-configuration.nix

echo "Deploying NixOS configuration..."
sudo nixos-rebuild switch

echo "Deployment complete!"
