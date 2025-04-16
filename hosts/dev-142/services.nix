# Services specific to dev-142
{ config, lib, pkgs, ... }:

{
  # MongoDB configuration
  services.mongodb = {
    enable = true;
    bind_ip = "0.0.0.0";
    port = 27017;
    extraConfig = ''
      storage:
        dbPath: /var/lib/mongodb
        journal:
          enabled: true
      systemLog:
        destination: file
        path: /var/log/mongodb/mongod.log
        logAppend: true
      net:
        bindIpAll: true
      processManagement:
        fork: true
      security:
        authorization: enabled
    '';
  };

  # InfluxDB time-series database
  services.influxdb = {
    enable = true;
    extraConfig = {
      http = {
        bind-address = ":8086";
        auth-enabled = true;
      };
    };
  };

  # MinIO S3-compatible object storage
  services.minio = {
    enable = true;
    region = "us-east-1";
    dataDir = "/var/lib/minio";
    configDir = "/etc/minio";
    rootCredentialsFile = "/etc/minio/creds"; # Create this file with MINIO_ROOT_USER and MINIO_ROOT_PASSWORD
  };

  # NFS server for shared storage
  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/shared 192.168.13.0/24(rw,sync,no_subtree_check,crossmnt,fsid=0)
    '';
  };

  # Create directories for data storage
  systemd.tmpfiles.rules = [
    "d /mnt/shared 0755 root root - -"
    "d /var/lib/mongodb 0700 mongodb mongodb - -"
    "d /var/log/mongodb 0755 mongodb mongodb - -"
    "d /var/lib/minio 0700 minio minio - -"
    "d /etc/minio 0700 minio minio - -"
  ];

  # Prometheus exporter for monitoring databases
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "systemd" "processes" "filesystem" "diskstats" "meminfo" ];
      port = 9100;
    };

    postgres = {
      enable = true;
      port = 9187;
      runAsLocalSuperUser = true;
    };

    redis = {
      enable = true;
      port = 9121;
      redisAddr = "localhost:6379";
    };
  };

  # Database backup services
  services.borgbackup.jobs = {
    postgresql-backup = {
      paths = [ "/var/lib/postgresql" ];
      repo = "/var/backup/postgresql";
      encryption.mode = "repokey";
      encryption.passphrase = "replace-with-secure-passphrase";
      compression = "auto,zstd";
      startAt = "daily";
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 6;
      };
      preHook = ''
        ${pkgs.postgresql}/bin/pg_dumpall -U postgres > /var/lib/postgresql/full_backup_$(date +%Y-%m-%d).sql
      '';
    };

    mongodb-backup = {
      paths = [ "/var/lib/mongodb" ];
      repo = "/var/backup/mongodb";
      encryption.mode = "repokey";
      encryption.passphrase = "replace-with-secure-passphrase";
      compression = "auto,zstd";
      startAt = "daily";
    };
  };

  # Monitoring dashboard
  services.grafana = {
    enable = true;
    domain = "dev-142.local";
    port = 3000;
    addr = "127.0.0.1";
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "InfluxDB";
          type = "influxdb";
          url = "http://localhost:8086";
          access = "proxy";
          isDefault = true;
        }
      ];
    };
  };

  # Web proxy for services
  services.nginx = {
    enable = true;
    virtualHosts."dev-142.local" = {
      locations."/grafana/" = {
        proxyPass = "http://localhost:3000/";
      };
      locations."/minio/" = {
        proxyPass = "http://localhost:9000/";
      };
    };
  };

  # Open web interface port
  networking.firewall.allowedTCPPorts = [ 80 443 3000 ];
}
