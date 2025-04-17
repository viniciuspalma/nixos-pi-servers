# Hardware configuration for dev-901 (Kubernetes Control Plane)
{ config, lib, pkgs, ... }:

{
  # Any control-plane specific hardware adjustments can go here
  # Use Raspberry Pi specific kernel
  # This is the kernel for the Pi 5/CM5
  boot  = {
    kernelPackages = pkgs.linuxPackagesFor pkgs.rpi-kernels.v6_12_17.bcm2712;
    kernel.sysctl = {
      # Increase for control plane components
        "vm.max_map_count" = 524288;
      };
  };

  # Configure swap with appropriate limit for control plane
  swapDevices = [{
    device = "/var/swapfile";
    size = 8192; # 8GB swap
  }];

  # Virtual machine support for testing if needed
  virtualisation.libvirtd.enable = true;
}
