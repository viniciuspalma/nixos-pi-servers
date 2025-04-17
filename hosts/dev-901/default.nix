# Configuration for dev-901 (Kubernetes Control Plane)
{ modulesPath, pkgs, ... }:

{
  imports = [
    ../../modules/disk-layouts
    ./hardware-specific.nix
    ../../modules/kubernetes/control-plane.nix
  ];

  # Host specific configuration
  networking = {
    hostName = "dev-901";

    # Static IP configuration (optional)
    # useDHCP = false;
    # interfaces.eth0.ipv4.addresses = [{
    #   address = "192.168.13.102";
    #   prefixLength = 24;
    # }];
    # defaultGateway = "192.168.13.1";
    # nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Host specific disk device
  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Bootloader configuration
  boot.loader.grub.devices = [ "/dev/nvme0n1" ];

  # Only include essential packages for Kubernetes management
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    etcdctl
    jq
  ];
}
