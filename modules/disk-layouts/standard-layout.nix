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
            MBR = {
              priority = 0;
              size = "1M";
              type = "EF02";
            };
            ESP = {
              priority = 1;
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
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
