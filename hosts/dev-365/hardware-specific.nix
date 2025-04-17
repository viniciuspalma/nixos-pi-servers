# Hardware configuration for dev-365 (Kubernetes Worker Node)
{ config, lib, pkgs, ... }:

{
  # Import standardized Kubernetes hardware configuration
  imports = [ ../common/hardware-kubernetes.nix ];

  # Worker-specific hardware adjustments (if needed)

  # Configure swap with appropriate limit
  swapDevices = [{
    device = "/var/swapfile";
    size = 4096; # 4GB swap
  }];
}
