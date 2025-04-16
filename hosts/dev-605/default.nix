# Configuration for dev-605
{ modulesPath, pkgs, ... }:

{
  imports = [
    ../../modules/disk-layouts
    ./hardware-specific.nix
    ./services.nix
  ];

  # Host specific configuration
  networking = {
    hostName = "dev-605";

    # Static IP configuration (optional)
    # useDHCP = false;
    # interfaces.eth0.ipv4.addresses = [{
    #   address = "192.168.13.101";
    #   prefixLength = 24;
    # }];
    # defaultGateway = "192.168.13.1";
    # nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Host specific disk device
  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Bootloader configuration
  boot.loader.grub.devices = [ "/dev/nvme0n1" ];

  # Role: Monitoring and Networking Server
  environment.systemPackages = with pkgs; [
    # Monitoring and networking tools
    prometheus
    grafana
    telegraf
    influxdb
    collectd
    loki
    logrotate
    goaccess
    wireshark
    nmap
    tcpdump
    iftop
    netdata
    traceroute
    mtr
    bind
    dhcp
    whois
    wireguard-tools
  ];

  # Services specific to this host
  services = {
    # Prometheus monitoring
    prometheus = {
      enable = true;
      port = 9090;

      # Basic scrape configs for the network
      scrapeConfigs = [
        {
          job_name = "node";
          static_configs = [{
            targets = [
              "dev-605:9100"  # Self
              "dev-365:9100"  # Development server
              "dev-901:9100"  # CI/CD server
              "dev-142:9100"  # Database server
            ];
            labels = {
              group = "production";
            };
          }];
        }
      ];

      # Rules for alerting
      rules = [
        ''
        groups:
          - name: example
            rules:
            - alert: InstanceDown
              expr: up == 0
              for: 5m
              labels:
                severity: critical
              annotations:
                summary: "Instance {{ $labels.instance }} down"
                description: "{{ $labels.instance }} has been down for more than 5 minutes."
        ''
      ];
    };

    # Node exporter for Prometheus
    prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" "processes" ];
      port = 9100;
    };
  };

  # Firewall adjustments for services
  networking.firewall.allowedTCPPorts = [
    9090      # Prometheus
    3000      # Grafana
    8086      # InfluxDB
    19999     # Netdata
    53        # DNS
  ];
}
