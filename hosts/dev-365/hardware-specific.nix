# Hardware-specific configuration for dev-365
{ config, lib, pkgs, ... }:

{
  # Hardware-specific settings
  hardware = {
    # CPU-specific optimizations
    cpu.intel.updateMicrocode = true;

    # GPU settings
    opengl = {
      enable = true;
      driSupport = true;
      setLdLibraryPath = true;
    };

    # Firmware and drivers
    enableAllFirmware = true;
  };

  # Kernel configuration
  boot = {
    kernelParams = [
      # SSD optimizations
      "elevator=noop"
    ];

    # Additional kernel modules
    kernelModules = [
      "i2c-dev"  # I2C support
    ];

    # Increase file descriptors
    kernel.sysctl = {
      "fs.file-max" = 100000;
      "net.core.somaxconn" = 1024;
    };
  };

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # Device-specific settings for this host
  services.udev.extraRules = ''
    # Custom udev rules for specific hardware
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="00:00:00:00:00:00", NAME="eth0"
  '';
}
