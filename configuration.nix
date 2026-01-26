# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
    ];

  # Enable flake
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.matx = {
    isNormalUser = true;
    description = "Mathieux Bergeron";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.chromium.enableWideVine = true;

  environment.variables = {
    # WLR_NO_HARDWARE_CURSORS = "1";
    # XCURSOR_SIZE = "48";
    # XCURSOR_THEME = "Adwaita";
    
    # Force Electron apps (like VSCode) to use Wayland and proper scaling
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
   ly
   neovim
   zsh
   oh-my-zsh
   zsh-autosuggestions
   zsh-syntax-highlighting
   alacritty
   chromium
   waybar
   git
   vscode
   tmux
   wl-clipboard
   wtype
   dotnet-sdk_10
   rofi
   hypridle    # Idle management for Hyprland
   hyprlock    # Screen locker for Hyprland
   hyprcursor  # Cursor theme system for Hyprland
   rose-pine-hyprcursor  # Rose Pine cursor theme for hyprcursor
   mako        # Notification daemon for Wayland
   spotify
   playerctl   # Media player control for Spotify and other players
   grim        # Screenshot tool for Wayland
   slurp       # Select a region in Wayland compositors
   swappy      # Wayland native snapshot editing tool
   imv         # Lightweight image viewer for Wayland
   mpv         # Lightweight video player for Wayland

   # Flaxe packages
   (builtins.getFlake "github:sadjow/claude-code-nix").packages.${pkgs.system}.default

  ];

  # Enable zsh
  programs.zsh.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Configure xdg-desktop-portal for Wayland
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  # Ensure user directories exist
  systemd.tmpfiles.rules = [
    "d /home/matx/Pictures 0755 matx users -"
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
