# Configuration for dev-605
{ modulesPath, ... }:

{
  imports = [
    ../../modules/disk-layouts
  ];

  # Host specific configuration
  networking.hostName = "dev-605";

  # Host specific disk device
  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Bootloader configuration
  boot.loader.grub.devices = [ "/dev/nvme0n1" ];
}
