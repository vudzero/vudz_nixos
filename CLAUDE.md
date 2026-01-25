# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a NixOS system configuration repository for a Parallels VM running on aarch64-linux architecture. The setup uses experimental Nix features (flakes and nix-command) and is configured for a Wayland-based environment with Sway/Hyprland window managers.

## System Configuration Structure

- `configuration.nix` - Main system configuration file
- `hardware-configuration.nix` - Auto-generated hardware-specific settings (do NOT modify directly)

The `configuration.nix` imports `hardware-configuration.nix` automatically.

## Key System Characteristics

- **Platform**: aarch64-linux (Parallels VM)
- **State Version**: 25.11
- **Hostname**: nixos
- **User**: matx (member of networkmanager and wheel groups)
- **Timezone**: America/Toronto
- **Locale**: en_CA.UTF-8
- **Display Manager**: ly
- **Window Managers**: Sway and Hyprland (Wayland compositors)

## Common Commands

### Applying Configuration Changes

```bash
# Build and activate new configuration (requires sudo)
sudo nixos-rebuild switch

# Build without activating (test configuration)
sudo nixos-rebuild build

# Test configuration temporarily (reverts on reboot)
sudo nixos-rebuild test
```

### Package Management

```bash
# Search for packages
nix search nixpkgs <package-name>

# Install packages by adding to environment.systemPackages in configuration.nix
# Then run: sudo nixos-rebuild switch
```

### Flake Operations

This system has experimental flakes enabled. The configuration references a flake package:
- `github:sadjow/claude-code-nix` (Claude Code Nix package)

## Important Configuration Details

### Unfree Packages
- Unfree packages are allowed system-wide via `nixpkgs.config.allowUnfree = true`
- Chromium has WideVine DRM enabled via `nixpkgs.config.chromium.enableWideVine = true`
- Parallels tools are allowed via a predicate in `hardware-configuration.nix`

### Wayland Environment Variables
The following environment variables are set for Wayland compatibility:
- `WLR_NO_HARDWARE_CURSORS = "1"` (required for some VMs)
- `XCURSOR_SIZE = "48"`
- `XCURSOR_THEME = "Adwaita"`

### Installed Terminals
Multiple terminal emulators are available: kitty, alacritty, ghostty

### Sway Configuration
Sway is configured with GTK wrappers enabled and includes the Adwaita icon theme.

## Modifying the System

When making changes:
1. Edit `configuration.nix` (never modify `hardware-configuration.nix`)
2. Test the configuration with `sudo nixos-rebuild build`
3. Apply changes with `sudo nixos-rebuild switch`
4. Respect the state version (currently 25.11) - do not change without reading NixOS documentation
