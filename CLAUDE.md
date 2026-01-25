# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a git-tracked NixOS system configuration repository for a Parallels VM running on aarch64-linux architecture. The setup uses experimental Nix features (flakes and nix-command) and is configured for a Wayland-based environment with Sway/Hyprland window managers.

## Repository Structure

- `configuration.nix` - Main system configuration file
- `hardware-configuration.nix` - Hardware-specific settings (typically auto-generated, but tracked in git)
- `deploy-nixos.sh` - Deployment script that copies configuration to /etc/nixos/ and applies changes

## Deployment Workflow

This repository serves as the source of truth for the NixOS configuration. The workflow is:

1. Edit configuration files in this git repository
2. Run `./deploy-nixos.sh` to:
   - Copy `configuration.nix` to `/etc/nixos/configuration.nix`
   - Copy `hardware-configuration.nix` to `/etc/nixos/hardware-configuration.nix`
   - Execute `sudo nixos-rebuild switch` to apply changes

### Common Commands

```bash
# Deploy configuration changes
./deploy-nixos.sh

# Test configuration without deploying (manual process)
sudo cp configuration.nix /etc/nixos/configuration.nix
sudo cp hardware-configuration.nix /etc/nixos/hardware-configuration.nix
sudo nixos-rebuild build

# Search for packages
nix search nixpkgs <package-name>
```

## Key System Characteristics

- **Platform**: aarch64-linux (Parallels VM)
- **State Version**: 25.11
- **Hostname**: nixos
- **User**: matx (member of networkmanager and wheel groups)
- **Timezone**: America/Toronto
- **Locale**: en_CA.UTF-8
- **Display Manager**: ly
- **Window Managers**: Sway and Hyprland (Wayland compositors)

## Important Configuration Details

### Unfree Packages
- Unfree packages are allowed system-wide via `nixpkgs.config.allowUnfree = true`
- Chromium has WideVine DRM enabled via `nixpkgs.config.chromium.enableWideVine = true`
- Parallels tools are allowed via a predicate in `hardware-configuration.nix`

### Wayland Environment Variables
The following environment variables are set for Wayland/VM compatibility:
- `WLR_NO_HARDWARE_CURSORS = "1"` (required for Parallels VM)
- `XCURSOR_SIZE = "48"`
- `XCURSOR_THEME = "Adwaita"`

### Flake Packages
This configuration uses a flake package: `github:sadjow/claude-code-nix` for Claude Code.

### Sway Configuration
Sway is configured with GTK wrappers enabled and includes the Adwaita icon theme.

## Adding Packages

To add new packages:
1. Edit `configuration.nix` and add the package name to `environment.systemPackages`
2. Run `./deploy-nixos.sh` to apply changes
3. Commit the changes to git

The state version (currently 25.11) should not be changed without reading NixOS documentation.
