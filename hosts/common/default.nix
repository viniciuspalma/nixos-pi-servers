# Common configuration for all hosts
{ lib, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./networking.nix
    ./ssh.nix
    ./system.nix
    ./users.nix
  ];

  # Common system configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Set a common state version
  system.stateVersion = "24.05";
}
