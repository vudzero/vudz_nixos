#!/usr/bin/env bash

set -e

# Parse args: optional machine name + flags
MACHINE=""
UPDATE_AGENTS=0
UPDATE_SYSTEM=0

usage() {
    echo "Usage: $0 [machine] [--update-agents] [--update-system]"
    echo ""
    echo "Deploy the NixOS flake for a machine. Package versions only change when"
    echo "flake inputs are updated — a plain deploy rebuilds the current lock."
    echo ""
    echo "Machines:"
    echo "  desktop | framework | laptop"
    echo "  (omit to auto-detect from hostname)"
    echo ""
    echo "Flags:"
    echo "  --update-agents   Update llm-agents + claude-desktop (claude, opencode,"
    echo "                    grok, Claude Desktop), then rebuild. Does not bump nixpkgs."
    echo "  --update-system   Update only the nixpkgs input, then rebuild."
    echo "                    Does not bump llm-agents or claude-desktop."
    echo ""
    echo "Examples:"
    echo "  $0                      # rebuild current lock (auto-detect machine)"
    echo "  $0 desktop              # rebuild for desktop"
    echo "  $0 --update-agents      # bump AI agents only, then rebuild"
    echo "  $0 laptop --update-agents"
}

for arg in "$@"; do
    case "$arg" in
        -h | --help)
            usage
            exit 0
            ;;
        --update-agents)
            UPDATE_AGENTS=1
            ;;
        --update-system)
            UPDATE_SYSTEM=1
            ;;
        -*)
            echo "Unknown option: $arg" >&2
            usage >&2
            exit 1
            ;;
        *)
            if [ -n "$MACHINE" ]; then
                echo "Error: multiple machine names given ('$MACHINE' and '$arg')" >&2
                exit 1
            fi
            MACHINE="$arg"
            ;;
    esac
done

if [ -z "$MACHINE" ]; then
    CURRENT_HOSTNAME=$(hostname)

    if [ "$CURRENT_HOSTNAME" = "desktop" ] || [ "$CURRENT_HOSTNAME" = "laptop" ] || [ "$CURRENT_HOSTNAME" = "framework" ]; then
        MACHINE="$CURRENT_HOSTNAME"
        echo "Auto-detected machine: $MACHINE"
    else
        usage >&2
        exit 1
    fi
fi

# Validate machine name
if [ ! -d "machines/$MACHINE" ]; then
    echo "Error: Machine '$MACHINE' not found in machines/ directory"
    exit 1
fi

MACHINE_DIR="machines/$MACHINE"

echo "Deploying configuration for: $MACHINE"
echo ""

# Check if hardware-configuration.nix exists in the repo
if [ ! -f "$MACHINE_DIR/hardware-configuration.nix" ]; then
    echo "Hardware configuration not found in $MACHINE_DIR/"

    # Check if it exists in /etc/nixos/
    if [ -f /etc/nixos/hardware-configuration.nix ]; then
        echo "Copying hardware-configuration.nix from /etc/nixos/ to $MACHINE_DIR/"
        cp /etc/nixos/hardware-configuration.nix "$MACHINE_DIR/hardware-configuration.nix"
        echo "Note: hardware-configuration.nix is not tracked in git (machine-specific)"
    else
        echo "ERROR: /etc/nixos/hardware-configuration.nix does not exist!"
        echo "Generate it with: sudo nixos-generate-config"
        exit 1
    fi
fi

# Optionally bump individual flake inputs before rebuild
if [ "$UPDATE_AGENTS" -eq 1 ]; then
    echo "Updating llm-agents + claude-desktop inputs (AI coding agents)..."
    nix flake update llm-agents claude-desktop
    echo ""
fi

if [ "$UPDATE_SYSTEM" -eq 1 ]; then
    echo "Updating nixpkgs input only (system packages)..."
    nix flake update nixpkgs
    echo ""
fi

echo "Deploying NixOS configuration with flake..."
sudo nixos-rebuild switch --flake ".#$MACHINE"

echo ""
echo "Deployment complete!"
echo ""
echo "Next steps:"
echo "  - Commit your changes: git add . && git commit -m 'Update configuration'"
echo "  - On a new machine, run: ./deploy-nixos.sh <machine-name>"
echo "  - Bump only AI agents later: ./deploy-nixos.sh --update-agents"
