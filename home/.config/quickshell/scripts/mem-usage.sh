#!/bin/bash
awk '/MemTotal:/{t=$2} /MemAvailable:/{a=$2} END {printf "RAM %.1fG\n", (t-a)/1048576}' /proc/meminfo
