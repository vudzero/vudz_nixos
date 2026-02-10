# Desktop-specific configuration
{ config, pkgs, ... }:

{
  imports = [
    ../../nvidia.nix # Load NVIDIA configuration for desktop
    ../../gaming.nix # Load gaming configuration (Steam, MangoHud, RetroArch)
  ];

  networking.hostName = "desktop";

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    # Add desktop-specific packages here
  ];
}
