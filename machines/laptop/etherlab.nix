# IgH EtherCAT master (EtherLab) — Kinova fork, built from local source.
#
# The source tree is provided by the flake input `etherlab` (a git+file
# checkout of ~/src/etherlab_master). Two packages are produced:
#   * ethercat-modules   — the ec_master / ec_generic kernel modules, built
#                          against this machine's kernel.
#   * ethercat-userspace — the `ethercat` CLI, libethercat and the ethercatctl
#                          control script.
#
# Only the `generic` Ethernet driver is built: the fork ships native EtherCAT
# drivers for r8169 only up to kernel 4.4, and this laptop's NICs are all
# Realtek (r8169 / r8152), so the generic driver (which runs over the standard
# kernel network stack) is the only viable option on kernel 6.x.
{
  config,
  pkgs,
  lib,
  etherlab,
  ...
}:

let
  kernel = config.boot.kernelPackages.kernel;
  version = "1.6.0-kinova";

  # Userspace tools and library. `--enable-kernel=no` keeps this independent of
  # the kernel; the modules are built by the separate derivation below.
  ethercat-userspace = pkgs.stdenv.mkDerivation {
    pname = "ethercat";
    inherit version;
    src = etherlab;

    nativeBuildInputs = with pkgs; [
      autoreconfHook
      pkg-config
    ];

    configureFlags = [
      "--enable-kernel=no"
      "--enable-userlib=yes"
      "--enable-tool=yes"
      # Absolute paths baked into ethercatctl (defaults are /sbin/* which do not
      # exist on NixOS).
      "--with-kmod-dir=${pkgs.kmod}/bin"
      "--with-ip-cmd=${pkgs.iproute2}/bin/ip"
      # The systemd unit is defined by NixOS below, not installed by the build.
      "--without-systemdsystemunitdir"
    ];

    enableParallelBuilding = true;

    meta = {
      description = "IgH EtherCAT master userspace tools (Kinova fork)";
      license = lib.licenses.gpl2Plus;
      platforms = [ "x86_64-linux" ];
    };
  };

  # Kernel modules built against the running kernel's build tree.
  ethercat-modules = pkgs.stdenv.mkDerivation {
    pname = "ethercat-modules";
    inherit version;
    src = etherlab;

    nativeBuildInputs =
      (with pkgs; [
        autoreconfHook
        pkg-config
      ])
      ++ kernel.moduleBuildDependencies;

    configureFlags = [
      "--with-linux-dir=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "--enable-kernel=yes"
      "--enable-generic"
      "--enable-hrtimer"
      "--enable-tool=no"
      "--enable-userlib=no"
      "--without-systemdsystemunitdir"
    ];

    buildPhase = ''
      runHook preBuild
      make modules
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      make modules_install INSTALL_MOD_PATH=$out
      runHook postInstall
    '';

    meta = {
      description = "IgH EtherCAT master kernel modules: ec_master, ec_generic (Kinova fork)";
      license = lib.licenses.gpl2Plus;
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  # Build ec_master / ec_generic against this kernel; depmod runs at activation.
  boot.extraModulePackages = [ ethercat-modules ];

  # `ethercat` CLI + libethercat available system-wide.
  environment.systemPackages = [ ethercat-userspace ];

  # /dev/EtherCATx character devices — readable/writable by the wheel group.
  services.udev.extraRules = ''
    KERNEL=="EtherCAT[0-9]*", MODE="0660", GROUP="wheel"
  '';

  # Fixed IP for enp195s0f0 (RTI DDS multicast/EtherCAT NIC). NetworkManager
  # must not touch it, since a static address is set declaratively below.
  networking.networkmanager.unmanaged = [ "enp195s0f0" ];
  networking.interfaces.enp195s0f0.ipv4.addresses = [
    {
      address = "192.168.1.13";
      prefixLength = 24;
    }
  ];

  # Master runtime configuration (sourced by ethercatctl).
  # Edit and redeploy to change the EtherCAT NIC or driver.
  environment.etc."ethercat.conf".text = ''
    # Onboard Realtek NIC (enp195s0f0), matched by MAC so it survives renames.
    MASTER0_DEVICE="18:3d:2d:85:e3:2c"

    # Generic driver: runs over the standard kernel net stack (no native
    # EtherCAT r8169 driver exists for kernel 6.x).
    DEVICE_MODULES="generic"

    # Left empty: ethercatctl would otherwise bring this interface down on
    # stop. The interface is kept up independently (see enp195s0f0-up.service
    # below) so it survives the master stopping/restarting.
    UPDOWN_INTERFACES=""
  '';

  # The generic driver needs enp195s0f0 up before the master starts, and it
  # must stay up regardless of the ethercat service's state (ethercatctl no
  # longer manages it — see UPDOWN_INTERFACES above).
  systemd.services."enp195s0f0-up" = {
    description = "Keep enp195s0f0 up for EtherCAT generic driver";
    wantedBy = [ "multi-user.target" ];
    before = [ "ethercat.service" ];
    path = [ pkgs.iproute2 ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip link set enp195s0f0 up";
    };
  };

  # systemd unit mirroring upstream ethercat.service, wired to NixOS paths and
  # /etc/ethercat.conf. Not enabled — start manually with:
  #   sudo systemctl start ethercat
  systemd.services.ethercat = {
    description = "EtherCAT Master Kernel Modules";
    after = [ "network.target" "enp195s0f0-up.service" ];
    wants = [ "enp195s0f0-up.service" ];
    path = with pkgs; [
      bash
      coreutils
      gnugrep
      gawk
      kmod
      iproute2
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${ethercat-userspace}/bin/ethercatctl -c /etc/ethercat.conf start";
      ExecStop = "${ethercat-userspace}/bin/ethercatctl -c /etc/ethercat.conf stop";
    };
  };
}
