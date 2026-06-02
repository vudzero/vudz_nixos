# configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./etherlab.nix ];

  networking.hostName = "laptop";

  # Use kernel 6.18
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Fix backlight/brightness control for newer kernels
  boot.kernelParams = [
    "acpi_backlight=native"
    "video.use_native_backlight=1"
    # MES (Micro Engine Scheduler) ring buffer fills up and never drains on
    # Strix Point APUs, causing a hard GPU hang that takes the whole system down.
    # Disabling MES falls back to CPU-side scheduling with no noticeable impact
    # on desktop workloads.
    "amdgpu.mes=0"
  ];
  hardware.acpilight.enable = true;

  # Enable PREEMPT_RT for realtime performance
  #boot.kernelPackages = pkgs.linuxPackages_6_12.extend (
  #  self: super: {
  #    kernel = super.kernel.override {
  #      structuredExtraConfig = with lib.kernel; {
  #        PREEMPT_RT = yes;
  #        PREEMPT_VOLUNTARY = lib.mkForce no;
  #      };
  #      ignoreConfigErrors = true;
  #    };
  #  }
  #);

  # Enable iwd for WiFi management (required by impala)
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Laptop power management
  services.thermald.enable = true;
  powerManagement.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Battery conservation
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    powertop # Power consumption analyzer
    acpi # Battery status tool
    impala # WiFi network manager
    brightnessctl # Brightness control tool
  ];
}
