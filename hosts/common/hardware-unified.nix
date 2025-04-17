# Unified hardware configuration for all nodes
{ config, lib, pkgs, ... }:

{
  # Basic hardware support
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
  };

  # Raspberry Pi specific configuration
  boot = {
    loader = {
      grub.enable = false;
    };

    kernelParams = [
      "console=tty1"
      "console=serial0,115200n8"
      # Keep existing performance params
      "elevator=none"
      "transparent_hugepage=madvise"
    ];

    # Use Raspberry Pi specific kernel
    kernelPackages = lib.mkDefault pkgs.linuxPackages_rpi4;

    initrd.availableKernelModules = [
      "pcie_brcmstb"     # Required for the PCIe bus to work
      "reset-raspberrypi" # Required for vl805 firmware to load
      "usb_storage"
      "usbhid"
      "vc4"             # VideoCore IV GPU
      # Keep existing modules for k8s
      "br_netfilter"
      "overlay"
      "nf_conntrack"
    ];

    # Boot optimizations - using mkDefault so hosts can override if needed
    kernel.sysctl = lib.mkDefault {
      # VM settings optimized for general use and containers
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 5;
      "vm.dirty_background_ratio" = 2;
      "vm.max_map_count" = 262144;
      "vm.min_free_kbytes" = 65536;

      # File system settings that benefit all workloads
      "fs.file-max" = 1000000;
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 8192;
      "fs.aio-max-nr" = 1048576;

      # Network settings optimized for general server use
      "net.core.somaxconn" = 32768;
      "net.core.netdev_max_backlog" = 10000;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.ipv4.tcp_max_syn_backlog" = 8096;
    };
  };
  # Power management optimized for server workloads
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # SSD optimizations
  services.fstrim.enable = true;

  # Disk IO scheduler optimizations
  services.udev.extraRules = ''
    # Set IO scheduler for NVMe drives
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    # Set IO scheduler for SSD
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # Set IO scheduler for HDD
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
  '';

  # System resource limits with reasonable defaults
  security.pam.loginLimits = lib.mkDefault [
    { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
    { domain = "*"; type = "soft"; item = "nproc"; value = "unlimited"; }
    { domain = "*"; type = "hard"; item = "nproc"; value = "unlimited"; }
  ];

  # System tuning via systemd
  systemd.extraConfig = lib.mkDefault ''
    DefaultTimeoutStartSec=90s
    DefaultTimeoutStopSec=90s
  '';
}
