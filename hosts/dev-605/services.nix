# Services specific to dev-605
{ config, lib, pkgs, ... }:

{
  # Grafana for visualization
  services.grafana = {
    enable = true;
    domain = "dev-605.local";
    port = 3000;

    # Default admin credentials (change these in production)
    security.adminUser = "admin";
    security.adminPasswordFile = pkgs.writeText "adminpass" "admin";

    # Automatic provisioning
    provision = {
      enable = true;
      # Add default data sources
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:9090";
          access = "proxy";
          isDefault = true;
        }
      ];
      # Add some default dashboards
      dashboards.settings.providers = [
        {
          name = "default";
          options.path = "/var/lib/grafana/dashboards";
        }
      ];
    };
  };

  # InfluxDB for time-series data
  services.influxdb = {
    enable = true;
    extraConfig = {
      http = {
        bind-address = ":8086";
        auth-enabled = true;
      };
    };
  };

  # Telegraf for metrics collection
  services.telegraf = {
    enable = true;
    extraConfig = {
      global_tags = {
        role = "monitoring";
      };
      agent = {
        interval = "10s";
        round_interval = true;
        metric_batch_size = 1000;
        collection_jitter = "0s";
      };
      outputs = {
        influxdb = {
          urls = [ "http://localhost:8086" ];
          database = "telegraf";
          skip_database_creation = false;
        };
      };
      inputs = {
        cpu = {
          percpu = true;
          totalcpu = true;
        };
        disk = {
          ignore_fs = [ "tmpfs" "devtmpfs" ];
        };
        diskio = {};
        kernel = {};
        mem = {};
        processes = {};
        swap = {};
        system = {};
        # Monitor all network interfaces
        net = {};
        # Monitor DNS queries
        dns_query = {
          servers = [ "127.0.0.1" ];
          domains = [ "example.com" ];
        };
        # HTTP response monitoring
        http_response = [
          {
            urls = [
              "http://dev-365.local"
              "http://dev-901.local"
              "http://dev-142.local"
            ];
            response_timeout = "5s";
            method = "GET";
          }
        ];
      };
    };
  };

  # Loki for log aggregation
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = 3100;
      };
      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store = "inmemory";
            };
            replication_factor = 1;
          };
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 1048576;
        chunk_retain_period = "30s";
      };
      schema_config = {
        configs = [{
          from = "2020-10-24";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };
      storage_config = {
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper-active";
          cache_location = "/var/lib/loki/boltdb-shipper-cache";
          cache_ttl = "24h";
          shared_store = "filesystem";
        };
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };
      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };
      chunk_store_config = {
        max_look_back_period = "0s";
      };
      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };
      compactor = {
        working_directory = "/var/lib/loki";
        shared_store = "filesystem";
        compactor_ring = {
          kvstore = {
            store = "inmemory";
          };
        };
      };
    };
  };

  # Promtail to ship logs to Loki
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 9080;
        grpc_listen_port = 0;
      };
      positions = {
        filename = "/var/lib/promtail/positions.yaml";
      };
      clients = [{
        url = "http://localhost:3100/loki/api/v1/push";
      }];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "${config.networking.hostName}";
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
          ];
        }
      ];
    };
  };

  # NetData for real-time monitoring
  services.netdata = {
    enable = true;
    config = {
      global = {
        "memory mode" = "ram";
        "history" = 3600;
        "update every" = 1;
      };
    };
  };

  # Bind DNS server
  services.bind = {
    enable = true;
    ipv4Only = false;

    zones = {
      "local.zone" = {
        master = true;
        file = pkgs.writeText "local.zone" ''
          $TTL 86400
          @ IN SOA dev-605.local. admin.dev-605.local. (
               2022070601 ; serial
               3600       ; refresh
               1800       ; retry
               604800     ; expire
               86400      ; minimum
          )

          @                       IN  NS      dev-605.local.
          dev-605.local.          IN  A       192.168.13.101
          dev-365.local.          IN  A       192.168.13.104
          dev-901.local.          IN  A       192.168.13.102
          dev-142.local.          IN  A       192.168.13.103
        '';
      };
    };
  };

  # Nginx for service dashboards
  services.nginx = {
    enable = true;

    # Main dashboard with links to all monitoring services
    virtualHosts."dev-605.local" = {
      locations."/" = {
        root = pkgs.writeTextDir "index.html" ''
          <!DOCTYPE html>
          <html>
          <head>
            <title>Dev-605 Monitoring Dashboard</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 0; padding: 20px; }
              h1 { color: #333; }
              .card { border: 1px solid #ddd; border-radius: 4px; padding: 15px; margin: 10px 0; }
              a { color: #06c; text-decoration: none; }
              a:hover { text-decoration: underline; }
            </style>
          </head>
          <body>
            <h1>Dev-605 Monitoring Dashboard</h1>

            <div class="card">
              <h2>Monitoring Systems</h2>
              <ul>
                <li><a href="/grafana/">Grafana</a> - Visualization and dashboards</li>
                <li><a href="/prometheus/">Prometheus</a> - Metrics and alerts</li>
                <li><a href="http://dev-605.local:19999">NetData</a> - Real-time performance monitoring</li>
              </ul>
            </div>

            <div class="card">
              <h2>Services</h2>
              <ul>
                <li><a href="http://dev-365.local">Development Server (dev-365)</a></li>
                <li><a href="http://dev-901.local">CI/CD Server (dev-901)</a></li>
                <li><a href="http://dev-142.local">Database Server (dev-142)</a></li>
              </ul>
            </div>
          </body>
          </html>
        '';
      };

      # Proxy Grafana
      locations."/grafana/" = {
        proxyPass = "http://localhost:3000/";
        extraConfig = ''
          proxy_set_header Host $host;
        '';
      };

      # Proxy Prometheus
      locations."/prometheus/" = {
        proxyPass = "http://localhost:9090/";
        extraConfig = ''
          proxy_set_header Host $host;
        '';
      };
    };
  };

  # Create directories for services
  systemd.tmpfiles.rules = [
    "d /var/lib/loki 0700 loki loki - -"
    "d /var/lib/loki/chunks 0700 loki loki - -"
    "d /var/lib/loki/boltdb-shipper-active 0700 loki loki - -"
    "d /var/lib/loki/boltdb-shipper-cache 0700 loki loki - -"
    "d /var/lib/promtail 0700 promtail promtail - -"
    "d /var/lib/grafana/dashboards 0700 grafana grafana - -"
  ];
}
