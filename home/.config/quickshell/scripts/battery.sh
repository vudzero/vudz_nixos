#!/bin/bash
bat_path=""
for p in /sys/class/power_supply/BAT*; do
    [ -f "$p/capacity" ] && bat_path="$p" && break
done
[ -z "$bat_path" ] && exit 0

cap=$(cat "$bat_path/capacity")
status=$(cat "$bat_path/status")

if [ "$status" = "Charging" ]; then
    echo "󰂄 ${cap}%"
elif [ "$status" = "Full" ]; then
    echo "󰚥 ${cap}%"
elif [ "$cap" -gt 80 ]; then echo " ${cap}%"
elif [ "$cap" -gt 60 ]; then echo " ${cap}%"
elif [ "$cap" -gt 40 ]; then echo " ${cap}%"
elif [ "$cap" -gt 20 ]; then echo " ${cap}%"
else echo " ${cap}%"
fi
