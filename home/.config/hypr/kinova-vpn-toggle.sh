#!/bin/bash
# Toggle kinova-vpn session: start if not running, disconnect if running

SESSION_PATH=$(openvpn3 sessions-list 2>/dev/null | grep -A1 "kinova-vpn" | grep "Path:" | awk '{print $2}')

if [ -n "$SESSION_PATH" ]; then
    openvpn3 session-manage --session-path "$SESSION_PATH" --disconnect
else
    openvpn3 session-start --config kinova-vpn
fi
