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
  services.upower.enable = true;

  # power-profiles-daemon handles CPU governors (replaces TLP)
  # and enables DMS power profile switching in the toolbar
  services.power-profiles-daemon.enable = true;

  # Battery charge conservation: stop charging at 80%, resume at 75%
  # power-profiles-daemon does not manage charge thresholds, so we do it here
  systemd.services.battery-charge-limit = {
    description = "Set battery charge thresholds";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "set-charge-limit" ''
        echo 75 > /sys/class/power_supply/BAT0/charge_control_start_threshold
        echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
      '';
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
