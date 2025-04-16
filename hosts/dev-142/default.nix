# Configuration for dev-142
{ modulesPath, pkgs, ... }:

{
  imports = [
    ../../modules/disk-layouts
    ./hardware-specific.nix
    ./services.nix
  ];

  # Host specific configuration
  networking = {
    hostName = "dev-142";

    # Static IP configuration (optional)
    # useDHCP = false;
    # interfaces.eth0.ipv4.addresses = [{
    #   address = "192.168.13.103";
    #   prefixLength = 24;
    # }];
    # defaultGateway = "192.168.13.1";
    # nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  # Host specific disk device
  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Bootloader configuration
  boot.loader.grub.devices = [ "/dev/nvme0n1" ];

  # Role: Database and Storage Server
  environment.systemPackages = with pkgs; [
    # Database and storage tools
    postgresql_15
    redis
    mongodb
    influxdb
    minio
    s3cmd
    restic
    rclone
    nfs-utils
    lvm2
    cryptsetup
  ];

  # Services specific to this host
  services = {
    # PostgreSQL
    postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      enableTCPIP = true;
      settings = {
        shared_buffers = "2GB";
        work_mem = "64MB";
        maintenance_work_mem = "256MB";
        effective_cache_size = "6GB";
        max_connections = "100";
      };
      authentication = pkgs.lib.mkOverride 10 ''
        local all all trust
        host all all 127.0.0.1/32 trust
        host all all ::1/128 trust
        host all all 192.168.13.0/24 md5
      '';
    };

    # Redis cache
    redis.servers.default = {
      enable = true;
      port = 6379;
      settings = {
        maxmemory = "2gb";
        maxmemory-policy = "allkeys-lru";
      };
    };
  };

  # Firewall adjustments for services
  networking.firewall.allowedTCPPorts = [
    5432      # PostgreSQL
    6379      # Redis
    27017     # MongoDB
    8086      # InfluxDB
    9000      # MinIO
    2049      # NFS
  ];
}
