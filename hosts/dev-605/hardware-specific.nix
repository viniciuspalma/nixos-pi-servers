# Hardware configuration for dev-605 (Kubernetes Worker Node)
{ config, lib, pkgs, ... }:

{
  # Worker-specific hardware adjustments (if needed)

  # Configure swap with appropriate limit
  swapDevices = [{
    device = "/var/swapfile";
    size = 4096; # 4GB swap
  }];

  # Additional packages for network debugging (useful for K8s networking issues)
  environment.systemPackages = with pkgs; [
    tcpdump
    iftop
    mtr
    nmap
  ];
}
