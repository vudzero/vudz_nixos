#!/usr/bin/env bash
# Import the Kinova OpenVPN 3 profile so it matches the framework desktop.
# The profile file (kinova.ovpn) is gitignored — copy it onto the machine first.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_NAME="kinova-vpn"
FORCE=0
OVPN=""

for arg in "$@"; do
    case "$arg" in
        --force) FORCE=1 ;;
        -*)
            echo "Unknown option: $arg" >&2
            echo "Usage: $0 [--force] [path/to/kinova.ovpn]" >&2
            exit 1
            ;;
        *)
            if [ -n "$OVPN" ]; then
                echo "Error: multiple profile paths given" >&2
                exit 1
            fi
            OVPN="$arg"
            ;;
    esac
done

OVPN="${OVPN:-$SCRIPT_DIR/kinova.ovpn}"

if ! command -v openvpn3 >/dev/null 2>&1; then
    echo "Error: openvpn3 is not installed. Deploy NixOS first (./deploy-nixos.sh)." >&2
    exit 1
fi

if openvpn3 config-manage --config "$PROFILE_NAME" --exists --quiet 2>/dev/null; then
    if [ "$FORCE" -eq 0 ]; then
        echo "Kinova VPN profile already imported ($PROFILE_NAME). Pass --force to replace it."
        exit 0
    fi
fi

if [ ! -f "$OVPN" ]; then
    echo "Error: VPN profile not found: $OVPN" >&2
    echo "Copy kinova.ovpn next to this script (it is gitignored), or pass a path:" >&2
    echo "  $0 /path/to/kinova.ovpn" >&2
    exit 1
fi

if openvpn3 config-manage --config "$PROFILE_NAME" --exists --quiet 2>/dev/null; then
    echo "Removing existing $PROFILE_NAME profile..."
    openvpn3 session-manage --disconnect --config "$PROFILE_NAME" >/dev/null 2>&1 || true
    openvpn3 config-remove --config "$PROFILE_NAME" --force
fi

echo "Importing $OVPN as persistent profile $PROFILE_NAME..."
openvpn3 config-import --config "$OVPN" --name "$PROFILE_NAME" --persistent
openvpn3 config-manage --config "$PROFILE_NAME" --persist-tun true --quiet

echo "Imported. Start or restart with:"
echo "  openvpn3 session-start --config $PROFILE_NAME"
echo "  or click the VPN button on the DMS bar"
