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
# drivers for r8169 only up to kernel 4.4, so the generic driver (which runs
# over the standard kernel network stack) is the only viable option on kernel
# 6.x.
#
# Import from a machine config and set hardware.ethercat.{interface,mac}.
# Optionally set ipv4Address to take the NIC away from NetworkManager and
# assign a static address (laptop robot network). Leave it unset on a
# workstation uplink.
{
  config,
  pkgs,
  lib,
  etherlab,
  ...
}:

let
  cfg = config.hardware.ethercat;
  kernel = config.boot.kernelPackages.kernel;
  version = "1.6.0-kinova";
  upService = "${cfg.interface}-up";

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
  options.hardware.ethercat = {
    interface = lib.mkOption {
      type = lib.types.str;
      example = "enp195s0f0";
      description = "Ethernet interface used by the generic EtherCAT driver.";
    };

    mac = lib.mkOption {
      type = lib.types.str;
      example = "18:3d:2d:85:e3:2c";
      description = "MAC address written to MASTER0_DEVICE in ethercat.conf.";
    };

    ipv4Address = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "192.168.1.13";
      description = ''
        If set, assign this static IPv4 address and mark the interface
        unmanaged by NetworkManager. Leave unset when the NIC is a normal
        workstation uplink.
      '';
    };

    ipv4PrefixLength = lib.mkOption {
      type = lib.types.ints.u8;
      default = 24;
      description = "Prefix length for hardware.ethercat.ipv4Address.";
    };
  };

  config = {
    # Build ec_master / ec_generic against this kernel; depmod runs at activation.
    boot.extraModulePackages = [ ethercat-modules ];

    # `ethercat` CLI + libethercat available system-wide.
    environment.systemPackages = [ ethercat-userspace ];

    # Prebuilt binaries look for libethercat by SONAME and at the FHS path
    # /usr/local/lib (IgH's default prefix), not the Nix store.
    programs.nix-ld.libraries = [ ethercat-userspace ];
    systemd.tmpfiles.rules = [
      "d /usr/local 0755 root root -"
      "d /usr/local/lib 0755 root root -"
      "d /usr/local/include 0755 root root -"
      "L+ /usr/local/lib/libethercat.so - - - - ${ethercat-userspace}/lib/libethercat.so"
      "L+ /usr/local/lib/libethercat.so.1 - - - - ${ethercat-userspace}/lib/libethercat.so.1"
      "L+ /usr/local/include/ecrt.h - - - - ${ethercat-userspace}/include/ecrt.h"
      "L+ /usr/local/include/ectty.h - - - - ${ethercat-userspace}/include/ectty.h"
    ];

    # /dev/EtherCATx character devices — readable/writable by the wheel group.
    services.udev.extraRules = ''
      KERNEL=="EtherCAT[0-9]*", MODE="0660", GROUP="wheel"
    '';

    networking.networkmanager.unmanaged = lib.mkIf (cfg.ipv4Address != null) [ cfg.interface ];
    networking.interfaces = lib.mkIf (cfg.ipv4Address != null) {
      ${cfg.interface}.ipv4.addresses = [
        {
          address = cfg.ipv4Address;
          prefixLength = cfg.ipv4PrefixLength;
        }
      ];
    };

    # Master runtime configuration (sourced by ethercatctl).
    # Edit and redeploy to change the EtherCAT NIC or driver.
    environment.etc."ethercat.conf".text = ''
      # Matched by MAC so it survives interface renames.
      MASTER0_DEVICE="${cfg.mac}"

      # Generic driver: runs over the standard kernel net stack (no native
      # EtherCAT r8169 driver exists for kernel 6.x).
      DEVICE_MODULES="generic"

      # Left empty: ethercatctl would otherwise bring this interface down on
      # stop. The interface is kept up independently (see ${upService}.service)
      # so it survives the master stopping/restarting.
      UPDOWN_INTERFACES=""
    '';

    # The generic driver needs the NIC up before the master starts, and it
    # must stay up regardless of the ethercat service's state (ethercatctl no
    # longer manages it — see UPDOWN_INTERFACES above).
    systemd.services.${upService} = {
      description = "Keep ${cfg.interface} up for EtherCAT generic driver";
      wantedBy = [ "multi-user.target" ];
      before = [ "ethercat.service" ];
      path = [ pkgs.iproute2 ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip link set ${cfg.interface} up";
      };
    };

    # systemd unit mirroring upstream ethercat.service, wired to NixOS paths and
    # /etc/ethercat.conf. Not enabled — start manually with:
    #   sudo systemctl start ethercat
    systemd.services.ethercat = {
      description = "EtherCAT Master Kernel Modules";
      after = [
        "network.target"
        "${upService}.service"
      ];
      wants = [ "${upService}.service" ];
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
  };
}
