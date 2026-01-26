{ config, pkgs, ... }:

{
  # Enable NVIDIA kernel modesetting for Wayland support
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Blacklist nouveau driver to prevent conflicts
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Enable 32-bit support for Steam and other apps
  };

  hardware.nvidia = {
    # Modesetting is required for Wayland compositors
    modesetting.enable = true;

    # Enable power management (helps with laptop usage, generally safe for desktop too)
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # Use the open source kernel module (recommended for RTX 4070 Ti)
    # Set to false if you experience issues
    open = false;

    # Enable the NVIDIA settings menu
    nvidiaSettings = true;

    # Select the appropriate driver version for RTX 4070 Ti
    # The "production" branch is the stable driver
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Environment variables for NVIDIA + Wayland
  environment.sessionVariables = {
    # GBM backend for NVIDIA (helps with some Wayland compositors)
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Might help with some rendering issues
    LIBVA_DRIVER_NAME = "nvidia";
  };

  systemd.services.nvidia-suspend.enable = true;
  systemd.services.nvidia-hibernate.enable = true;
  systemd.services.nvidia-resume.enable = true;
}
