# Network configuration for all hosts
{ lib, ... }:

{
  # Basic networking configuration
  networking = {
    # Use DHCP by default (can be overridden in specific host configurations)
    useDHCP = lib.mkDefault true;

    # Configure the firewall
    firewall = {
      enable = true;
      allowPing = true;

      # Open specific TCP ports
      allowedTCPPorts = [
        22    # SSH
        # Add more ports as needed
      ];

      # Open specific UDP ports
      allowedUDPPorts = [
        # Add ports as needed
      ];
    };

    # Configure network time sync
    timeServers = [
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "2.nixos.pool.ntp.org"
      "3.nixos.pool.ntp.org"
    ];
  };

  # Enable the NetworkManager service for hosts that need it
  # networking.networkmanager.enable = lib.mkDefault false;

  # Enable mDNS for local name resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
  };

  # systemd-resolved for DNS resolution
  services.resolved = {
    enable = true;
    dnssec = "false";
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Time synchronization
  services.timesyncd.enable = true;
}
