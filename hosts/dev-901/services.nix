# Services specific to dev-901
{ config, lib, pkgs, ... }:

{
  # Docker registry for CI/CD pipeline
  services.dockerRegistry = {
    enable = true;
    port = 5000;
    enableDelete = true;
    enableGarbageCollect = true;
    garbageCollectDates = "weekly";
  };

  # Nginx for reverse proxy to services
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "dev-901.local" = {
        serverName = "dev-901.local";
        serverAliases = [ "dev-901" "ci" "ci.local" ];

        # Jenkins proxy
        locations."/jenkins" = {
          proxyPass = "http://localhost:8080";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };

        # Docker registry proxy
        locations."/v2" = {
          proxyPass = "http://localhost:5000";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
    };
  };

  # Monitoring services
  services.prometheus = {
    enable = true;
    port = 9090;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9100;
      };

      jenkins = {
        enable = true;
        port = 9102;
        configuration = {
          jenkins = {
            address = "http://localhost:8080";
          };
        };
      };
    };

    # Basic scrape configs
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [{
          targets = [ "localhost:9100" ];
        }];
      }
      {
        job_name = "jenkins";
        static_configs = [{
          targets = [ "localhost:9102" ];
        }];
      }
    ];
  };

  # Grafana for monitoring visualization
  services.grafana = {
    enable = true;
    port = 3000;
    domain = "dev-901.local";
    rootUrl = "http://dev-901.local/grafana/";

    # Add prometheus as a data source
    provision = {
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:9090";
            isDefault = true;
          }
        ];
      };
    };
  };

  # Add Grafana to Nginx
  services.nginx.virtualHosts."dev-901.local".locations."/grafana/" = {
    proxyPass = "http://localhost:3000/";
    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';
  };

  # Automatic backup for CI/CD data
  services.borgbackup.jobs.ci-backup = {
    paths = [
      "/var/lib/jenkins"
      "/var/lib/docker-registry"
      "/var/lib/prometheus"
      "/var/lib/grafana"
    ];
    exclude = [
      "*/workspace"
      "*/builds"
    ];
    repo = "/var/backup/dev-901";
    encryption = {
      mode = "repokey";
      passphrase = "replace-with-secure-passphrase";
    };
    compression = "auto,zstd";
    startAt = "daily";
  };
}
