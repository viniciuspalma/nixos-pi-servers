# Kubernetes worker node configuration
{ config, lib, pkgs, k8s, ... }:

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
      network = k8s.podSubnet;
    };

    # Default master address (can be overridden in node-specific config)
    masterAddress = "dev-901";
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
    kubectl
    cri-tools # Container runtime interface tools
  ];
}
