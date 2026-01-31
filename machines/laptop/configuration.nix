# Laptop-specific configuration
{ config, pkgs, lib, ... }:

{
  networking.hostName = "laptop";

  # Enable PREEMPT_RT for realtime performance
  boot.kernelPackages = pkgs.linuxPackages_6_12.extend (self: super: {
    kernel = super.kernel.override {
      structuredExtraConfig = with lib.kernel; {
        PREEMPT_RT = yes;
        PREEMPT_VOLUNTARY = lib.mkForce no;
      };
      ignoreConfigErrors = true;
    };
  });

  # Enable iwd for WiFi management (required by impala)
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  # Laptop power management
  services.thermald.enable = true;
  powerManagement.enable = true;

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
  ];
}
