#!/bin/bash
read -ra f1 < <(head -1 /proc/stat)
t1=$(( f1[1]+f1[2]+f1[3]+f1[4]+f1[5]+f1[6]+f1[7] ))
i1=$(( f1[4]+f1[5] ))
sleep 0.2
read -ra f2 < <(head -1 /proc/stat)
t2=$(( f2[1]+f2[2]+f2[3]+f2[4]+f2[5]+f2[6]+f2[7] ))
i2=$(( f2[4]+f2[5] ))
dt=$(( t2 - t1 ))
di=$(( i2 - i1 ))
[ "$dt" -gt 0 ] && echo "CPU $(( 100 * (dt - di) / dt ))%" || echo "CPU --%"
