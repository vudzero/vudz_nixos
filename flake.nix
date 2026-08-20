{
  description = "Multi-machine NixOS configuration";

  # Numtide binary cache for prebuilt llm-agents packages (claude-code, opencode, grok, …)
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # AI coding agents (claude-code, opencode, grok, …). Separate input so
    # `nix flake update llm-agents` (or ./deploy-nixos.sh --update-agents)
    # bumps only agents — not the rest of the system.
    # Intentionally does NOT follow nixpkgs (keeps Numtide's prebuilt cache).
    llm-agents.url = "github:numtide/llm-agents.nix";
    # Unofficial wrap of Anthropic's official Linux .deb (Chat / Cowork / Code).
    # Bumped with the other agents via ./deploy-nixos.sh --update-agents.
    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Local checkout of the Kinova EtherCAT master fork (laptop only). Tracks
    # committed state on the `development` branch; run
    # `nix flake lock --update-input etherlab` after committing source changes.
    etherlab = {
      url = "git+file:///home/matx/src/etherlab_master?ref=development";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      llm-agents,
      claude-desktop,
      etherlab,
      ...
    }:
    let
      mkSystem =
        { system, modules }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = modules ++ [
            {
              _module.args = {
                inherit llm-agents claude-desktop;
              };
            }
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
            # EtherCAT source, passed only to the laptop so other machines never
            # force (and therefore never need to fetch) the etherlab input.
            { _module.args.etherlab = etherlab; }
          ];
        };

      };
    };
}
