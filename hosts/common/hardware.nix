# Common hardware configuration for all hosts
{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Common boot configuration
  boot = {
    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
    initrd.availableKernelModules = [ "ehci_pci" "xhci_pci" "virtio_pci" "virtio_scsi" "ahci" "sd_mod" "sr_mod" ];
    kernelModules = [ "kvm-intel" ];
  };

  # Common hardware settings
  hardware.enableRedistributableFirmware = true;
}
