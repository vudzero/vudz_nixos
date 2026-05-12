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

  # Enable GameMode for gaming performance
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # Gaming packages
  environment.systemPackages = with pkgs; [
    godot
    godot_4-mono
    mangohud # Performance overlay for games
    (retroarch.withCores (
      cores: with cores; [
        snes9x # Fast, highly compatible SNES core
        mupen64plus # Nintendo 64 core for retroarch
        pcsx_rearmed # PlayStation 1 core for retroarch
        beetle-psx-hw # Beetle PSX HW - Hardware-accelerated PS1 core
        swanstation # PlayStation 1 core (DuckStation fork)
        pcsx2 # PlayStation 2 core for retroarch
      ]
    ))
  ];
}
