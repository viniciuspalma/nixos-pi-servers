# Configuration for dev-365
{ modulesPath, ... }:

{
  imports = [
    ../../modules/disk-layouts
  ];

  # Host specific configuration
  networking.hostName = "dev-365";

  # Host specific disk device
  disko.devices.disk.main.device = "/dev/sda";

  # Bootloader configuration
  boot.loader.grub.devices = [ "/dev/sda" ];
}
