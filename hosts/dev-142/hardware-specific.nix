# Hardware-specific configuration for dev-142
{ config, lib, pkgs, ... }:

{
  # Hardware-specific settings
  hardware = {
    # CPU-specific optimizations
    cpu.intel.updateMicrocode = true;

    # Enable all firmware
    enableAllFirmware = true;
  };

  # Kernel configuration for database workloads
  boot = {
    kernelParams = [
      # IO scheduler optimizations
      "elevator=deadline"
      # Memory management for database workloads
      "transparent_hugepage=madvise"
    ];

    # Adjust kernel settings for database performance
    kernel.sysctl = {
      # Virtual memory settings
      "vm.swappiness" = 1;
      "vm.dirty_ratio" = 40;
      "vm.dirty_background_ratio" = 10;
      "vm.min_free_kbytes" = 65536;

      # File system settings
      "fs.file-max" = 500000;
      "fs.aio-max-nr" = 1048576;

      # Network settings
      "net.core.somaxconn" = 4096;
      "net.ipv4.tcp_max_syn_backlog" = 4096;
      "net.ipv4.tcp_fin_timeout" = 30;
      "net.ipv4.tcp_keepalive_intvl" = 15;
      "net.ipv4.tcp_keepalive_probes" = 5;
      "net.ipv4.tcp_keepalive_time" = 300;
    };
  };

  # Filesystems configuration
  fileSystems = {
    # Optimize the root filesystem for database operations
    "/" = {
      options = [ "noatime" "nodiratime" "discard" ];
    };

    # Create a separate filesystem for database data
    "/var/lib/postgresql" = {
      device = "/dev/disk/by-label/pgdata";
      fsType = "ext4";
      options = [ "noatime" "data=ordered" "discard" ];
      # This is a placeholder. You'll need to create this partition/label during setup
      autoFormat = true;
      formatOptions = [ "-L" "pgdata" ];
    };
  };

  # Configure swap with higher limit for database operations
  swapDevices = [{
    device = "/var/swapfile";
    size = 16384; # 16GB swap for database operations
  }];

  # Power management optimized for server workloads
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # Configure IO scheduler for database performance
  services.udev.extraRules = ''
    # Set IO scheduler for NVMe drive
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    # Set IO scheduler for other disks
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="deadline"
  '';

  # System tuning via systemd
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=90s
    DefaultTimeoutStopSec=90s
  '';
}
