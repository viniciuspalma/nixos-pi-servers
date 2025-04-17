# Standardized hardware configuration for Kubernetes nodes
{ config, lib, pkgs, ... }:

{
  # Basic hardware support
  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
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

  # Boot loader with latest kernel
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    # Kernel modules needed for Kubernetes
    kernelModules = [ "br_netfilter" "overlay" "nf_conntrack" ];

    # Kernel parameters for Kubernetes
    kernelParams = [
      # General performance
      "elevator=none"
      # Container optimizations
      "cgroup_enable=memory"
      "cgroup_memory=1"
      # SSD optimizations
      "transparent_hugepage=madvise"
    ];

    # Boot optimizations
    kernel.sysctl = {
      # VM settings optimized for containers
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 5;
      "vm.dirty_background_ratio" = 2;
      "vm.max_map_count" = 262144;
      "vm.min_free_kbytes" = 65536;

      # File system settings for container workloads
      "fs.file-max" = 1000000;
      "fs.inotify.max_user_watches" = 524288;
      "fs.inotify.max_user_instances" = 8192;
      "fs.aio-max-nr" = 1048576;

      # Network settings optimized for Kubernetes
      "net.core.somaxconn" = 32768;
      "net.core.netdev_max_backlog" = 10000;
      "net.core.rmem_max" = 16777216;
      "net.core.wmem_max" = 16777216;
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.ipv4.tcp_max_syn_backlog" = 8096;

      # Required for Kubernetes networking
      "net.bridge.bridge-nf-call-iptables" = 1;
      "net.bridge.bridge-nf-call-ip6tables" = 1;
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.default.rp_filter" = 0;
      "net.ipv4.conf.all.rp_filter" = 0;

      # Connection tracking for services
      "net.netfilter.nf_conntrack_max" = 1048576;
    };
  };

  # System resource limits for container workloads
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "1048576"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "1048576"; }
    { domain = "*"; type = "soft"; item = "nproc"; value = "unlimited"; }
    { domain = "*"; type = "hard"; item = "nproc"; value = "unlimited"; }
  ];

  # System tuning via systemd
  systemd.extraConfig = ''
    DefaultTimeoutStartSec=90s
    DefaultTimeoutStopSec=90s
  '';
}
