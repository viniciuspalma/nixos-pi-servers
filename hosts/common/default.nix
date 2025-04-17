# Common configuration for all hosts
{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-unified.nix
    ./networking.nix
    ./ssh.nix
    ./system.nix
    ./users.nix
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

    overlays = [inputs.raspberry-pi-nix.overlays.core];
  };

  # Set a common state version
  system.stateVersion = "24.05";
}
