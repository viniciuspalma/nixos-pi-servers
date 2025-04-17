# Kubernetes control plane configuration
{ config, lib, pkgs, ... }:

{
  imports = [
    ./default.nix
  ];

  # Override the roles for master node
  services.kubernetes = {
    roles = ["master" "node"];

    # API server configuration
    apiserver = {
      enable = true;
      serviceClusterIpRange = config.services.kubernetes.commonClusterConfig.serviceClusterIpRange;
      advertiseAddress = config.networking.primaryIPAddress;
      allowPrivileged = true;
      securePort = 6443;
      # For single-node setup or simple deployment
      authorizationMode = ["RBAC" "Node"];
      extraSANs = ["dev-901"];
    };

    # Controller manager configuration
    controllerManager = {
      enable = true;
      serviceClusterIpRange = config.services.kubernetes.commonClusterConfig.serviceClusterIpRange;
      clusterCidr = config.services.kubernetes.commonClusterConfig.podSubnet;
    };

    # Scheduler configuration
    scheduler = {
      enable = true;
    };

    # Basic Flannel CNI networking
    flannel = {
      enable = true;
      network = config.services.kubernetes.commonClusterConfig.podSubnet;
    };

    # Enable proxy on the control plane
    proxy = {
      enable = true;
    };

    # Set master address to self for control-plane
    masterAddress = config.networking.primaryIPAddress;

    # Configure etcd on control-plane
    etcd = {
      enable = true;
      listenClientUrls = ["https://127.0.0.1:2379" "https://${config.networking.primaryIPAddress}:2379"];
      advertiseClientUrls = ["https://${config.networking.primaryIPAddress}:2379"];
    };
  };

  # Open additional ports for control plane
  networking.firewall = {
    allowedTCPPorts = [
      # Kubernetes API server
      6443
      # etcd server client API
      2379 2380
      # Kubernetes scheduler
      10251
      # Kubernetes controller manager
      10252
      # Flannel overlay network
      8472
    ];

    # For Flannel UDP
    allowedUDPPorts = [
      8472
    ];
  };

  # Add control plane specific packages
  environment.systemPackages = with pkgs; [
    kubernetes-helm
    etcdctl
  ];
}
