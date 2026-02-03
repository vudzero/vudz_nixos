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
  ];
}
