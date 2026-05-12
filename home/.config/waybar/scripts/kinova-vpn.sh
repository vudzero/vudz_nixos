#!/bin/bash
# Outputs JSON status for waybar custom/kinova-vpn module

STATUS=$(openvpn3 sessions-list 2>/dev/null | grep -A5 "kinova-vpn" | grep "Status:" | sed 's/.*Status: //')

if echo "$STATUS" | grep -qi "connected"; then
    echo '{"text": "󰖂", "class": "connected", "tooltip": "Kinova VPN: Connected"}'
elif [ -n "$STATUS" ]; then
    ESCAPED=$(echo "$STATUS" | sed 's/"/\\"/g')
    echo "{\"text\": \"󰖂\", \"class\": \"connecting\", \"tooltip\": \"Kinova VPN: $ESCAPED\"}"
else
    echo '{"text": "󰖂", "class": "disconnected", "tooltip": "Kinova VPN: Disconnected"}'
fi
