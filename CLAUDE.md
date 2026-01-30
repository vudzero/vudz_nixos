# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a git-tracked NixOS system configuration repository that can be deployed across multiple machines. The setup uses experimental Nix features (flakes and nix-command) and is configured for a Wayland-based environment with Hyprland window manager.

## Repository Structure

- `flake.nix` - Flake definition with multiple machine configurations
- `common.nix` - Shared configuration across all machines (tracked in git)
- `nvidia.nix` - NVIDIA GPU configuration (used by desktop only)
- `machines/desktop/` - Desktop-specific configuration
  - `configuration.nix` - Desktop settings (imports nvidia.nix)
  - `hardware-configuration.nix` - Hardware scan (NOT tracked in git)
- `machines/laptop/` - Laptop-specific configuration
  - `configuration.nix` - Laptop settings (power management, no NVIDIA)
  - `hardware-configuration.nix` - Hardware scan (NOT tracked in git)
- `deploy-nixos.sh` - Deployment script for flake-based configuration

## Deployment Workflow

This repository uses a flake-based multi-machine configuration. The workflow is:

### First-time setup on a new machine:
1. Generate the hardware configuration: `sudo nixos-generate-config`
2. Clone this repository
3. Run `./deploy-nixos.sh <machine-name>` (e.g., `./deploy-nixos.sh desktop`)
   - Script will copy hardware-configuration.nix from /etc/nixos/ to machines/<machine-name>/
   - Runs `sudo nixos-rebuild switch --flake .#<machine-name>`

### Subsequent deployments:
1. Edit configuration files in this git repository
   - `common.nix` for changes affecting all machines
   - `machines/<machine-name>/configuration.nix` for machine-specific changes
2. Run `./deploy-nixos.sh <machine-name>` to apply changes
   - If your hostname is "desktop" or "laptop", you can omit the machine name

### Common Commands

```bash
# First-time setup
sudo nixos-generate-config

# Deploy configuration changes
./deploy-nixos.sh desktop   # For desktop machine
./deploy-nixos.sh laptop    # For laptop machine
./deploy-nixos.sh           # Auto-detect based on hostname

# Test configuration without deploying
sudo nixos-rebuild build --flake .#desktop

# Update flake inputs
nix flake update

# Search for packages
nix search nixpkgs <package-name>
```

## Key System Characteristics

- **Platform**: Portable (supports aarch64-linux and x86_64-linux)
- **State Version**: 25.11
- **Machines**:
  - **desktop**: Desktop with NVIDIA RTX 4070 Ti GPU
  - **laptop**: Laptop with power management (TLP, thermald)
- **User**: matx (member of networkmanager and wheel groups)
- **Timezone**: America/Toronto
- **Locale**: en_CA.UTF-8
- **Display Manager**: ly
- **Window Manager**: Hyprland (Wayland compositor)

## Important Configuration Details

### Unfree Packages
- Unfree packages are allowed system-wide via `nixpkgs.config.allowUnfree = true`
- Chromium has WideVine DRM enabled via `nixpkgs.config.chromium.enableWideVine = true`

### Wayland Environment Variables
The following environment variables are set for Wayland compatibility:
- `WLR_NO_HARDWARE_CURSORS = "1"` (useful for VMs and some hardware)
- `XCURSOR_SIZE = "48"`
- `XCURSOR_THEME = "Adwaita"`

### Flake Packages
This configuration uses a flake package: `github:sadjow/claude-code-nix` for Claude Code.

### Hyprland Configuration
Hyprland is configured with:
- Idle management via `hypridle` (turns off display after 10 minutes, suspends after 15 minutes)
- Screen locking via `hyprlock`
- Auto-start of waybar, terminal, and browser
- Configuration files located in `home/.config/hypr/`

## Adding Packages

To add new packages:
1. Edit `common.nix` for packages on all machines, or `machines/<machine-name>/configuration.nix` for machine-specific packages
2. Run `./deploy-nixos.sh <machine-name>` to apply changes
3. Commit the changes to git

## Adding a New Machine

To add a new machine to this configuration:
1. Create a new directory: `machines/<new-machine-name>/`
2. Create `machines/<new-machine-name>/configuration.nix` with machine-specific settings
3. Add the machine to `flake.nix` in the `nixosConfigurations` section
4. On the new machine, run `sudo nixos-generate-config` to generate hardware-configuration.nix
5. Run `./deploy-nixos.sh <new-machine-name>` to deploy

The state version (currently 25.11) should not be changed without reading NixOS documentation.
