# Services specific to dev-365
{ config, lib, pkgs, ... }:

{
  # Web server for development
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."dev-365.local" = {
      serverName = "dev-365.local";
      serverAliases = [ "dev-365" ];
      root = "/var/www/dev-365";

      locations."/" = {
        index = "index.html index.htm";
      };

      # Example proxy configuration for a development API
      locations."/api/" = {
        proxyPass = "http://localhost:3000/";
        extraConfig = ''
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;
        '';
      };
    };
  };

  # Development environment services
  services = {
    # Git server
    gitea = {
      enable = true;
      appName = "Dev Git Server";
      domain = "dev-365.local";
      rootUrl = "http://dev-365.local:3000/";
      httpPort = 3000;
      settings = {
        service.DISABLE_REGISTRATION = true;
        service.REQUIRE_SIGNIN_VIEW = true;
      };
    };

    # Docker for containerized development
    docker = {
      enable = true;
      autoPrune.enable = true;
      autoPrune.dates = "weekly";
    };
  };

  # Create web directory with proper permissions
  systemd.tmpfiles.rules = [
    "d /var/www/dev-365 0755 nginx nginx - -"
    "f /var/www/dev-365/index.html 0644 nginx nginx - <h1>Welcome to dev-365</h1>"
  ];

  # Set up the backup service for development data
  services.borgbackup.jobs.dev-backup = {
    paths = [
      "/var/lib/postgresql"
      "/var/lib/gitea"
      "/var/www"
    ];
    exclude = [
      "*/node_modules"
      "*/target"
      "*/.git"
    ];
    repo = "/var/backup/dev-365";
    encryption = {
      mode = "repokey";
      passphrase = "replace-with-your-passphrase";
    };
    compression = "auto,zstd";
    startAt = "daily";
  };
}
