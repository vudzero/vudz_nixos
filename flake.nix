{
  description = "Multi-machine NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = { self, nixpkgs, claude-code, ... }: {
    nixosConfigurations = {
      # Desktop machine with NVIDIA GPU
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit claude-code; };
        modules = [
          ./machines/desktop/hardware-configuration.nix
          ./machines/desktop/configuration.nix
          ./common.nix
        ];
      };

      # Laptop machine (no NVIDIA)
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit claude-code; };
        modules = [
          ./machines/laptop/hardware-configuration.nix
          ./machines/laptop/configuration.nix
          ./common.nix
        ];
      };
    };
  };
}
