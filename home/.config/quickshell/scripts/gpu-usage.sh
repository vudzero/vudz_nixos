#!/bin/bash
util=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' ')
[ -n "$util" ] && echo "GPU ${util}%"
