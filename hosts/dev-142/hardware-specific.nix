# Hardware configuration for dev-142 (Kubernetes Worker Node)
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Worker-specific hardware adjustments (if needed)

  # Configure swap with appropriate limit
  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8192; # 8GB swap
    }
  ];

  # Keep the PostgreSQL filesystem in case we want to run a database in K8s
  # and use local storage
  # fileSystems = {
  #   "/var/lib/postgresql" = {
  #     device = "/dev/disk/by-label/pgdata";
  #     fsType = "ext4";
  #     options = [ "noatime" "data=ordered" "discard" ];
  #     autoFormat = true;
  #   };
  # };
}
