# Desktop-specific configuration
{ config, pkgs, ... }:

{
  imports = [
    ../../nvidia.nix # Load NVIDIA configuration for desktop
  ];

  networking.hostName = "desktop";

  # Enable Steam (desktop only for gaming)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Desktop-specific packages (gaming, streaming, etc.)
  environment.systemPackages = with pkgs; [
    mangohud # Performance overlay for games
    lutris # Gaming platform manager
    wine # Windows compatibility layer
    wine64 # 64-bit Wine support
    winetricks # Wine helper script for installing dependencies
    vulkan-loader # Vulkan ICD loader
    vulkan-tools # Vulkan utilities (vulkaninfo, etc.)
    vulkan-validation-layers # Vulkan debugging layers
  ];
}
