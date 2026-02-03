{
  description = "Multi-machine NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    {
      nixosConfigurations = {
        # Desktop machine with NVIDIA GPU
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/desktop/hardware-configuration.nix
            ./machines/desktop/configuration.nix
            ./common.nix
          ];
        };

        # Laptop machine
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/laptop/hardware-configuration.nix
            ./machines/laptop/configuration.nix
            ./common.nix
          ];
        };
      };
    };
}
