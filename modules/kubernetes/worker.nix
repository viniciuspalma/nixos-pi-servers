# Kubernetes worker node configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./default.nix
  ];

  # Override the roles for worker nodes
  services.kubernetes = {
    # Only worker role
    roles = ["node"];

    # Enable Kubernetes proxy on worker nodes
    proxy.enable = true;

    # Configure flannel on worker nodes
    flannel = {
      enable = true;
      network = config.services.kubernetes.commonClusterConfig.podSubnet;
    };

    # Point to the master node (would be replaced with actual control plane address)
    masterAddress = "kube-master.local";
  };

  # Open additional ports for worker nodes and flannel networking
  networking.firewall = {
    allowedTCPPorts = [
      # Flannel overlay network
      8472
    ];

    # For Flannel UDP
    allowedUDPPorts = [
      8472
    ];
  };

  # Worker-specific packages
  environment.systemPackages = with pkgs; [
    cri-tools # Container runtime interface tools
  ];
}
