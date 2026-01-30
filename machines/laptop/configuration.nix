# Laptop-specific configuration
{ config, pkgs, ... }:

{
  networking.hostName = "laptop";

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
    powertop  # Power consumption analyzer
    acpi      # Battery status tool
    impala    # WiFi network manager
  ];
}
