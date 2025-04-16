# Standard disk layout for all machines
{ ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # The device will be set by the host-specific configuration
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition
            BIOS = {
              priority = 0;
              size = "1M";
              type = "EF02"; # BIOS boot partition
              flags = ["bios_grub"];
            };
            # Boot partition
            boot = {
              priority = 1;
              size = "512M";
              type = "8300"; # Linux filesystem
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/boot";
              };
            };
            # Root partition
            root = {
              priority = 2;
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
