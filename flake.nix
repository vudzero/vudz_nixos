{
  description = "Multi-machine NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Pinned: v1.15.5+ bump packageManager to bun@1.3.14, which isn't in nixpkgs
    # yet (only 1.3.13). v1.15.4 is the newest release that still builds.
    opencode.url = "github:anomalyco/opencode/2b92c5677e83";
    claudeCode.url = "github:sadjow/claude-code-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      opencode,
      claudeCode,
      ...
    }:
    let
      mkSystem =
        { system, modules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = modules ++ [
            { _module.args.opencode = opencode; }
            { _module.args.claudeCode = claudeCode; }
          ];
        };
    in
    {
      nixosConfigurations = {
        # Desktop machine with NVIDIA GPU
        desktop = mkSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/desktop/hardware-configuration.nix
            ./machines/desktop/configuration.nix
            ./common.nix
          ];
        };

        # Framework desktop machine
        framework = mkSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/framework/hardware-configuration.nix
            ./machines/framework/configuration.nix
            ./common.nix
          ];
        };

        # Laptop machine
        laptop = mkSystem {
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
