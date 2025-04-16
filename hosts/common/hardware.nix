# Common hardware configuration for all hosts
{ lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Common boot configuration for BIOS mode (not EFI)
  boot = {
    loader.grub = {
      efiSupport = false;
      efiInstallAsRemovable = false;
    };
    initrd.availableKernelModules = [ "ehci_pci" "xhci_pci" "virtio_pci" "virtio_scsi" "ahci" "sd_mod" "sr_mod" "nvme" ];
    kernelModules = [ "kvm-intel" ];
  };

  # Common hardware settings
  hardware.enableRedistributableFirmware = true;
}
