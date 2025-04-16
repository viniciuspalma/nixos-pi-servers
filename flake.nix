{
  description = "NixOS configuration for multiple machines";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, nixos-anywhere, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Helper function to create a NixOS configuration for a host
      mkHost = hostname: {
        ${hostname} = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit disko nixos-anywhere;
          };
          modules = [
            ./hosts/${hostname}
            ./hosts/common
            disko.nixosModules.disko
          ];
        };
      };

      # List of all host names
      hostnames = [
        "dev-365"
        "dev-901"
        "dev-142"
        "dev-605"
      ];

      # Create configurations for all hosts
      nixosConfigurations = nixpkgs.lib.foldl' (acc: hostname:
        acc // (mkHost hostname)
      ) {} hostnames;

    in {
      inherit nixosConfigurations;

      # Expose formatter
      formatter.${system} = pkgs.nixpkgs-fmt;
    };
}
