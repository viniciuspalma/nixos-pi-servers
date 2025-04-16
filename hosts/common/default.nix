# Common configuration for all hosts
{ lib, ... }:

{
  imports = [
    ./users.nix
    ./ssh.nix
    ./hardware.nix
  ];

  # Common system configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Basic networking setup
  networking = {
    firewall.enable = true;
    useDHCP = lib.mkDefault true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
  ];

  # Set a common state version
  system.stateVersion = "24.05";
}
