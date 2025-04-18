# Kubernetes control plane configuration
{
  config,
  lib,
  pkgs,
  k8s,
  ...
}: let
  primaryIPAddress = "192.168.13.102";
in {
  imports = [
    ./default.nix
  ];

  # Override the roles for master node
  services.kubernetes = {
    roles = ["master" "node"];

    # API server configuration
    apiserver = {
      enable = true;
      serviceClusterIpRange = k8s.serviceClusterIpRange;
      advertiseAddress = primaryIPAddress;
      allowPrivileged = true;
      securePort = 6443;
      # For single-node setup or simple deployment
      authorizationMode = ["RBAC" "Node"];
      extraSANs = ["dev-901"];
    };

    # Controller manager configuration
    controllerManager = {
      enable = true;
      #   serviceClusterIpRange = k8s.serviceClusterIpRange;
      clusterCidr = k8s.podSubnet;
    };

    # Scheduler configuration
    scheduler = {
      enable = true;
    };

    # Basic Flannel CNI networking
    flannel = {
      enable = true;
      openFirewallPorts = true;
    };

    # Enable proxy on the control plane
    proxy = {
      enable = true;
    };

    # Set master address to self for control-plane
    masterAddress = primaryIPAddress;
  };

  services.etcd = {
    enable = true;
    listenClientUrls = ["http://127.0.0.1:2379"];
    advertiseClientUrls = ["http://127.0.0.1:2379"];
  };

  # Open additional ports for control plane
  networking.firewall = {
    allowedTCPPorts = [
      # Kubernetes API server
      6443
      # etcd server client API
      2379
      2380
      # Kubernetes scheduler
      10251
      # Kubernetes controller manager
      10252
    ];
  };

  # Add control plane specific packages
  environment.systemPackages = with pkgs; [
    kubernetes-helm
  ];
}
