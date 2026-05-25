#!/bin/bash
STATUS=$(openvpn3 sessions-list 2>/dev/null | grep -A5 "kinova-vpn" | grep "Status:" | sed 's/.*Status: //')
if echo "$STATUS" | grep -qi "connected"; then
    echo "󰖂|connected"
elif [ -n "$STATUS" ]; then
    echo "󰖂|connecting"
else
    echo "󰖂|disconnected"
fi
