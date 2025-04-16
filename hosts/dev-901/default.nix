# Configuration for dev-901
{ modulesPath, pkgs, ... }:

{
  imports = [
    ../../modules/disk-layouts
    ./hardware-specific.nix
    ./services.nix
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

  # Role: CI/CD Server
  environment.systemPackages = with pkgs; [
    # Build tools
    docker-compose
    jenkins
    git
    gnumake
    gcc
    python3
    python3Packages.pip
    buildah
    podman
    skopeo
  ];

  # Services specific to this host
  services = {
    # Jenkins automation server
    jenkins = {
      enable = true;
      package = pkgs.jenkins;
      port = 8080;
      user = "jenkins";
      group = "jenkins";
      extraGroups = [ "docker" ];
      environment = {
        JENKINS_HOME = "/var/lib/jenkins";
      };
      plugins = [
        "git"
        "workflow-aggregator"
        "docker-plugin"
        "pipeline"
        "job-dsl"
        "blueocean"
      ];
    };
  };

  # Firewall adjustments for services
  networking.firewall.allowedTCPPorts = [
    80 443    # Web
    8080      # Jenkins
    5000      # Docker registry
  ];
}
