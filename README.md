# NixOS Configuration

Portable NixOS system configuration for Wayland-based environments with Sway/Hyprland.

## First-Time Setup on a New Machine

1. Install NixOS (if not already installed)

2. Generate hardware configuration:
   ```bash
   sudo nixos-generate-config
   ```

3. Clone this repository:
   ```bash
   git clone <repository-url>
   cd vudz_nixos_setup
   ```

4. Deploy the configuration:
   ```bash
   ./deploy-nixos.sh
   ```

## Updating Configuration

1. Edit `configuration.nix` in this repository
2. Run `./deploy-nixos.sh` to apply changes
3. Commit changes to git

## Important Notes

- `hardware-configuration.nix` is **not tracked** in this repository
- Each machine generates its own hardware configuration
- This configuration is portable across x86_64-linux and aarch64-linux

## What's Included

- **Window Managers**: Sway and Hyprland
- **Display Manager**: ly
- **Terminal**: Alacritty
- **Browser**: Chromium (with WideVine DRM)
- **Editor**: VSCode, Neovim
- **Shell**: Zsh with Oh My Zsh
- **Development**: .NET SDK 10, Git, Tmux
- **Tools**: Claude Code, Rofi, Waybar, wl-clipboard

## See Also

- `CLAUDE.md` - Detailed documentation for Claude Code
