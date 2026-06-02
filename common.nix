# Common configuration shared across all machines
{
  config,
  pkgs,
  opencode,
  claudeCode,
  ...
}:

{
  # Enable flake
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Automatic garbage collection to keep only last 5 generationsopencode-flake.packages.${pkgs.system}.default
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than +5"; # Keep 5 most recent generations
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # Keep only last 5 generations in boot menu
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable zram for memory compression
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Fast compression algorithm
    memoryPercent = 50; # Use 50% of RAM for zram (8GB → ~16-24GB compressed)
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable systemd-resolved for DNS management (required by openvpn3)
  services.resolved.enable = true;

  # Block Spotify self-update domains
  networking.hosts = {
    "0.0.0.0" = [
      "upgrade.scdn.co"
      "upgrade.spotify.com"
    ];
  };

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
      "libvirtd"
      "vmware"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Font configuration
  fonts.packages = with pkgs; [
    (nerd-fonts.jetbrains-mono)
  ];

  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable Flatpak
  services.flatpak.enable = true;

  # Enable libvirt for QEMU/KVM virtualization
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true; # TPM emulation for Windows 11
    };
  };

  # Enable VMware Workstation
  virtualisation.vmware.host = {
    enable = true;
    package = pkgs.vmware-workstation;
  };

  environment.variables = {
    # Force Electron apps (like VSCode) to use Wayland and proper scaling
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    neovim # Text Editor
    zsh # Terminal Shell
    alacritty # Terminal emulator
    google-chrome # Browser
    firefox # Browser
    quickshell # Wayland shell toolkit (bar/panel)
    git # Code version control
    lazygit # TUI for git operations
    ripgrep # Search tool
    vscode-fhs # Code editor with FHS environment for extensions
    jetbrains.rider # .NET IDE

    wl-clipboard # OS Clipboard
    wtype # Wayland typing tool
    jq # JSON processor for scripts
    hyprcursor # Cursor theme system for Hyprland
    rose-pine-hyprcursor # Rose Pine cursor theme for hyprcursor
    libnotify # Send desktop notifications (provides notify-send)
    spotify # Music player
    discord # Chat tool
    playerctl # Media player control for Spotify and other players
    grim # Screenshot tool for Wayland
    slurp # Select a region in Wayland compositors
    swappy # Wayland native snapshot editing tool
    wl-screenrec # Screen recorder for Wayland (outputs mp4)
    imv # Lightweight image viewer for Wayland
    mpv # Lightweight video player for Wayland
    nautilus # GNOME file manager
    carapace # Multi-shell completion generator
    zsh-completions # Additional zsh completion definitions
    nodejs # JavaScript runtime (needed for Mason LSP servers)
    clang-tools # C/C++ language server (includes clangd)
    cmake # Cross-platform build system
    gnumake # GNU Make build tool
    gcc # GNU C/C++ compiler (includes g++)
    autoconf # Generates configure scripts (provides autoreconf)
    automake # Generates Makefile.in (used by autoreconf)
    libtool # Generic library support (used by autoreconf)
    pkgconf # Compiler/linker flags helper (provides pkgconf)
    pkg-config # Provides the pkg-config command (pkgconf backend)
    config.boot.kernelPackages.kernel.dev # Kernel build headers matching the running kernel
    dotnet-sdk_10 # .NET 10 SDK
    tailwindcss_4 # Tailwindcss V4 Cli
    openvpn # OpenVPN client for office VPN
    nixfmt # Nix File formatter
    btop # TUI system monitor for CPU/RAM/disk/network
    unzip # File compression utility
    opencode.packages.${pkgs.system}.default # OpenCode AI Assistant (from flake)
    claudeCode.packages.${pkgs.system}.default # Claude Code AI Assistant (from flake)
    python314 # Python3 runtime
    sound-theme-freedesktop # Freedesktop sound theme for system sounds
    openvpn3 # Open VPN 3 Client
    transmission_4-gtk # Lightweight GUI BitTorrent client
    pdfarranger # Edit pdf pages
    kdePackages.okular # Fill PDF forms and annotate documents
    tableplus # Database manager
    libsecret # Secret storage library for applications

    # Tmux and plugins
    tmux
    tmuxPlugins.resurrect
    tmuxPlugins.continuum
  ];

  # Enable zsh with plugins
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Enable OpenVPN 3
  programs.openvpn3.enable = true;

  # Enable DankMaterialShell (DMS) — a complete desktop shell for Wayland
  programs.dms-shell = {
    enable = true;

    systemd = {
      enable = true;
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
  };

  # Enable GNOME Keyring for secure password storage
  services.gnome.gnome-keyring.enable = true;

  # Enable GVFS for Nautilus USB automount support
  services.gvfs.enable = true;

  # Enable udisks2 for USB auto-mounting
  services.udisks2.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    config = {
      user.name = "Mathieux Bergeron";
      user.email = "mbergeron@kinova.ca";
    };
  };

  # Display manager and window manager
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

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

  # Create symlinks for tmux plugins so they can be loaded from /etc/tmux-plugins
  environment.etc."tmux-plugins/resurrect".source =
    "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect";
  environment.etc."tmux-plugins/continuum".source =
    "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum";

  # State version
  system.stateVersion = "25.11";
}
