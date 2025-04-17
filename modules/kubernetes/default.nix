# Common Kubernetes configuration
{ config, lib, pkgs, ... }:

{
  # Enable container runtime
  virtualisation.containerd = {
    enable = true;
    settings = {
      version = 2;
      plugins."io.containerd.grpc.v1.cri" = {
        sandbox_image = "registry.k8s.io/pause:3.8";
        containerd.runtimes.runc.options = {
          SystemdCgroup = true;
        };
      };
    };
  };

  # Enable Kubernetes-related services
  services = {
    # Enable kubelet on all nodes
    kubernetes = {
      roles = ["node"];

      # Common kubelet configuration
      kubelet = {
        enable = true;
        extraOpts = "--fail-swap-on=false"; # Raspberry Pi may not have swap
        nodeIp = config.networking.primaryIPAddress;
        containerRuntimeEndpoint = "unix:///run/containerd/containerd.sock";
      };

      # Shared cluster configuration
      commonClusterConfig = {
        serviceClusterIpRange = "10.96.0.0/12";
        podSubnet = "10.244.0.0/16"; # For Flannel network
      };
    };
  };

  # Open ports for Kubernetes
  networking.firewall = {
    allowedTCPPorts = [
      # Kubelet API
      10250
      # NodePort Services
      30000 30001 30002 30003 30004 30005 30006 30007 30008 30009
      30010 30011 30012 30013 30014 30015 30016 30017 30018 30019
      30020 30021 30022 30023 30024 30025 30026 30027 30028 30029
      30030 30031 30032 30033 30034 30035 30036 30037 30038 30039
      30040 30041 30042 30043 30044 30045 30046 30047 30048 30049
      30050 30051 30052 30053 30054 30055 30056 30057 30058 30059
      30060 30061 30062 30063 30064 30065 30066 30067 30068 30069
      30070 30071 30072 30073 30074 30075 30076 30077 30078 30079
      30080 30081 30082 30083 30084 30085 30086 30087 30088 30089
      30090 30091 30092 30093 30094 30095
    ];
  };

  # Required packages for all Kubernetes nodes
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes
    ethtool
    socat
    util-linux
    iproute2
    iptables
    ebtables
    ipset
    containerd
    runc
  ];

  # Required for network plugin
  boot.extraModulePackages = [
    config.boot.kernelPackages.wireguard
  ];

  # Kernel modules needed for Kubernetes
  boot.kernelModules = [ "br_netfilter" "overlay" ];

  # Kernel settings for Kubernetes
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "net.ipv4.ip_forward" = 1;
  };
}
