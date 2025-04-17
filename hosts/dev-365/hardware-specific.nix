# Hardware configuration for dev-365 (Kubernetes Worker Node)
{ config, lib, pkgs, ... }:

{
  # Worker-specific hardware adjustments (if needed)

  # Configure swap with appropriate limit
  swapDevices = [{
    device = "/var/swapfile";
    size = 4096; # 4GB swap
  }];
}
