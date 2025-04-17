# Unified hardware configuration for all nodes
{ config, lib, pkgs, ... }:

{
  # Basic hardware support
  hardware = {
    enableAllFirmware = true;
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

  # Boot configuration
  boot = {
    # Latest kernel packages
    kernelPackages = pkgs.linuxPackages_latest;

    # Kernel modules - can be conditionally loaded based on host config
    kernelModules = lib.mkDefault [ "br_netfilter" "overlay" "nf_conntrack" ];

    # Kernel parameters - with reasonable defaults for both standard and k8s nodes
    kernelParams = lib.mkDefault [
      # General performance
      "elevator=none"
      # Container optimizations that don't harm regular systems
      "transparent_hugepage=madvise"
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
