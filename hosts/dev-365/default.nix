# Configuration for dev-365
{ modulesPath, pkgs, ... }:

{
  imports = [
    ../../modules/disk-layouts
    ./hardware-specific.nix
    ./services.nix
  ];

  # Host specific configuration
  networking = {
    hostName = "dev-365";

    # Static IP configuration (optional)
    # useDHCP = false;
    # interfaces.eth0.ipv4.addresses = [{
    #   address = "192.168.13.104";
    #   prefixLength = 24;
    # }];
    # defaultGateway = "192.168.13.1";
    # nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Host specific disk device
  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Bootloader configuration
  boot.loader.grub.devices = [ "/dev/nvme0n1" ];

  # Role: Primary Development Server
  environment.systemPackages = with pkgs; [
    # Development tools
    nodejs
    rustup
    go
    vscode-server
    gcc
    gnumake
    python3
  ];

  # Services specific to this host
  services = {
    # PostgreSQL database server
    postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      enableTCPIP = true;
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
      '';
      initialScript = pkgs.writeText "backend-initScript" ''
        CREATE ROLE admin WITH LOGIN PASSWORD 'admin' CREATEDB;
        CREATE DATABASE development;
        GRANT ALL PRIVILEGES ON DATABASE development TO admin;
      '';
    };
  };

  # Firewall adjustments for services
  networking.firewall.allowedTCPPorts = [
    80 443    # Web
    5432      # PostgreSQL
  ];
}
