# Common configuration shared across all machines
{
  config,
  pkgs,
  claude-code,
  ...
}:

{
  # Enable flake
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Automatic garbage collection to keep only last 5 generations
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than +5"; # Keep 5 most recent generations
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Keep only last 5 generations in boot menu
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Set your time zone
  time.timeZone = "America/Toronto";

  # Select internationalisation properties
  i18n.defaultLocale = "en_CA.UTF-8";

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account
  users.users.matx = {
    isNormalUser = true;
    description = "Mathieux Bergeron";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Docker
  virtualisation.docker.enable = true;

  environment.variables = {
    # Force Electron apps (like VSCode) to use Wayland and proper scaling
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    ly # Display Manager (Login Screen)
    neovim # Text Editor
    zsh # Terminal Shell
    alacritty # Terminal emulator
    google-chrome # Browser
    firefox # Browser
    waybar # OS Toolbar
    git # Code version control
    ripgrep # Search tool
    vscode # Code editor
    tmux # Terminal multiplexe
    wl-clipboard # OS Clipboard
    wtype # Wayland typing tool
    jq # JSON processor for scripts
    walker # App launcher
    hypridle # Idle management for Hyprland
    hyprlock # Screen locker for Hyprland
    hyprpaper # Wallpaper manager for Hyprland
    hyprcursor # Cursor theme system for Hyprland
    rose-pine-hyprcursor # Rose Pine cursor theme for hyprcursor
    mako # Notification daemon for Wayland
    libnotify # Send desktop notifications (provides notify-send)
    spotify # Music player
    discord # Chat tool
    playerctl # Media player control for Spotify and other players
    grim # Screenshot tool for Wayland
    slurp # Select a region in Wayland compositors
    swappy # Wayland native snapshot editing tool
    imv # Lightweight image viewer for Wayland
    mpv # Lightweight video player for Wayland
    nautilus # GNOME Files file manager
    carapace # Multi-shell completion generator
    zsh-completions # Additional zsh completion definitions
    blueman # Bluetooth manager with system tray applet
    nodejs # JavaScript runtime (needed for Mason LSP servers)
    openvpn # OpenVPN client for office VPN
    nixfmt # Nix File formatter

    # Flake packages
    claude-code.packages.${pkgs.system}.default
  ];

  # Enable zsh with plugins
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Display manager and window manager
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable blueman service for bluetooth management
  services.blueman.enable = true;

  # Enable PipeWire audio service
  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true; # PulseAudio compatibility
    alsa = {
      enable = true;
      support32Bit = true; # For Steam games
    };
    wireplumber.enable = true; # Session manager
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

  # State version
  system.stateVersion = "25.11";
}
