# Common hardware configuration for all nodes
{ config, lib, pkgs, ... }:

{
  # Enable all firmware
  hardware.enableAllFirmware = true;

  # Intel microcode updates
  hardware.cpu.intel.updateMicrocode = true;

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # SSD optimizations
  services.fstrim.enable = true;

  # Disk IO scheduler optimizations for NVMe
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

    # Boot optimizations
    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 3;
      "vm.dirty_background_ratio" = 2;
    };
  };
}
