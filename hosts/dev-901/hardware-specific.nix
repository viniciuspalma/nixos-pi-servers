# Hardware-specific configuration for dev-901
{ config, lib, pkgs, ... }:

{
  # Hardware-specific settings
  hardware = {
    # CPU-specific optimizations
    cpu.intel.updateMicrocode = true;

    # Firmware and drivers
    enableAllFirmware = true;
  };

  # Kernel configuration for CI/CD workloads
  boot = {
    kernelParams = [
      # SSD optimizations
      "elevator=noop"
      # CI/CD optimizations
      "transparent_hugepage=always"
    ];

    # Increase virtual memory for build jobs
    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.dirty_ratio" = 60;
      "vm.dirty_background_ratio" = 2;
      # Increase file descriptors for parallel builds
      "fs.file-max" = 200000;
      # Network tuning
      "net.core.somaxconn" = 4096;
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_tw_reuse" = 1;
    };

    # Enable virtualization features
    extraModprobeConfig = ''
      options kvm_intel nested=1
    '';
  };

  # Configure swap with higher limit for CI/CD builds
  swapDevices = [{
    device = "/var/swapfile";
    size = 8192; # 8GB swap
  }];

  # Power management optimized for server workloads
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # Configure IO scheduler for build performance
  services.udev.extraRules = ''
    # Set IO scheduler for NVMe SSD
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
  '';

  # Virtual machine support for testing
  virtualisation = {
    libvirtd.enable = true;

    # Docker for CI/CD
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune.enable = true;

      # Docker daemon settings
      extraOptions = "--storage-driver=overlay2";

      # Docker registry mirror
      extraOptions = ''
        --registry-mirror=https://mirror.gcr.io
      '';
    };
  };
}
