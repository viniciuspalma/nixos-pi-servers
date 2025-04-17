# Hardware configuration for dev-901 (Kubernetes Control Plane)
{ config, lib, pkgs, ... }:

{
  # Import standardized Kubernetes hardware configuration
  imports = [ ../common/hardware-kubernetes.nix ];

  # Any control-plane specific hardware adjustments can go here

  # Additional memory for etcd and apiserver
  boot.kernel.sysctl = {
    # Increase for control plane components
    "vm.max_map_count" = 524288;
  };

  # Configure swap with appropriate limit for control plane
  swapDevices = [{
    device = "/var/swapfile";
    size = 8192; # 8GB swap
  }];

  # Virtual machine support for testing if needed
  virtualisation.libvirtd.enable = true;
}
