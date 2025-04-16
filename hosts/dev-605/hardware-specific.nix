# Hardware-specific configuration for dev-605
{ config, lib, pkgs, ... }:

{
  # Hardware-specific settings
  hardware = {
    # CPU-specific optimizations
    cpu.intel.updateMicrocode = true;

    # Enable all firmware
    enableAllFirmware = true;
  };

  # Kernel configuration for monitoring workloads
  boot = {
    kernelParams = [
      # SSD optimizations
      "elevator=noop"
      # Enable more detailed network statistics
      "net.ifnames=0"
    ];

    # Adjust kernel settings for network monitoring
    kernel.sysctl = {
      # Network monitoring settings
      "net.core.rmem_max" = 26214400;
      "net.core.wmem_max" = 26214400;
      "net.core.rmem_default" = 65536;
      "net.core.wmem_default" = 65536;
      "net.core.netdev_max_backlog" = 5000;

      # TCP settings for better monitoring
      "net.ipv4.tcp_rmem" = "4096 87380 16777216";
      "net.ipv4.tcp_wmem" = "4096 65536 16777216";
      "net.ipv4.tcp_max_syn_backlog" = 8096;
      "net.ipv4.tcp_slow_start_after_idle" = 0;

      # For packet capture
      "net.core.bpf_jit_enable" = 1;

      # Enable packet forwarding for network routing
      "net.ipv4.ip_forward" = 1;
    };
  };

  # Power management optimized for server workloads
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # Allow packet capture for non-root users
  security.wrappers.dumpcap = {
    source = "${pkgs.wireshark}/bin/dumpcap";
    capabilities = "cap_net_raw,cap_net_admin+eip";
    owner = "root";
    group = "wireshark";
    permissions = "750";
  };

  # Create a special group for packet capture
  users.groups.wireshark = {};

  # Add admins to the wireshark group
  users.users.admin.extraGroups = [ "wireshark" ];

  # Configure IO scheduler for monitoring performance
  services.udev.extraRules = ''
    # Set IO scheduler for NVMe drive
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
  '';
}
