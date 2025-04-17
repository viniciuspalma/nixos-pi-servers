# Configuration for dev-142 (Kubernetes Worker Node)
{ modulesPath, pkgs, ... }:

{
  imports = [
    ../../modules/disk-layouts
    ./hardware-specific.nix
    ../../modules/kubernetes/worker.nix
  ];

  # Host specific configuration
  networking = {
    hostName = "dev-142";

    useDHCP = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.13.103";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
  };

  # Override Kubernetes master address to point to dev-901
  services.kubernetes.masterAddress = "dev-901";

  # Host specific disk device
  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Bootloader configuration
  boot.loader.grub.devices = [ "/dev/nvme0n1" ];

  # Only include essential packages for Kubernetes node
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
  ];
}
