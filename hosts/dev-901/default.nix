# Configuration for dev-901
{ modulesPath, ... }:

{
  imports = [
    ../../modules/disk-layouts
  ];

  # Host specific configuration
  networking.hostName = "dev-901";

  # Host specific disk device
  disko.devices.disk.main.device = "/dev/sda";

  # Bootloader configuration
  boot.loader.grub.devices = [ "/dev/sda" ];
}
