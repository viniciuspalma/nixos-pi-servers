# Common configuration for all hosts
{
  lib,
  pkgs,
  raspberry-pi-nix,
  ...
}: {
  imports = [
    ./hardware-unified.nix
    ./networking.nix
    ./ssh.nix
    ./system.nix
    ./users.nix
    ../../modules/disk-layouts
  ];

  # Common system configuration
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    auto-optimise-store = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };

    overlays = [raspberry-pi-nix.overlays.core];
  };

  # Set a common state version
  system.stateVersion = "24.05";
}
