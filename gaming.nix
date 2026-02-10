# Gaming configuration (Steam, MangoHud, RetroArch)
# This module can be imported on any machine that needs gaming capabilities
{ config, pkgs, ... }:

{
  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Gaming packages
  environment.systemPackages = with pkgs; [
    mangohud # Performance overlay for games
    (retroarch.withCores (
      cores: with cores; [
        snes9x # Fast, highly compatible SNES core
        mupen64plus # Nintendo 64 core for retroarch
        pcsx_rearmed # PlayStation 1 core for retroarch
        beetle-psx-hw # Beetle PSX HW - Hardware-accelerated PS1 core
      ]
    ))
  ];
}
