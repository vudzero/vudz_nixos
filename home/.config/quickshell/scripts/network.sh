#!/bin/bash
iface=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}')
if [ -z "$iface" ]; then
    echo "󰖪"
elif [[ "$iface" == wl* ]]; then
    echo ""
else
    echo ""
fi
