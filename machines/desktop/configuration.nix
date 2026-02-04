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
    rtorrent
    (retroarch.withCores (
      cores: with cores; [
        snes9x # Fast, highly compatible SNES core (recommended for most users)<grok-card data-id="1db765" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card>
        # bsnes   # Cycle-accurate alternative (more demanding, but perfect emulation)<grok-card data-id="7789a1" data-type="citation_card" data-plain-type="render_inline_citation" ></grok-card>
        mupen64plus # Nintendo 64 core for retroarch
        pcsx_rearmed # PlayStation 1 core for retroarch
        beetle-psx-hw # Beetle PSX HW - Hardware-accelerated PS1 core (Mednafen)
      ]
    ))
  ];
}
