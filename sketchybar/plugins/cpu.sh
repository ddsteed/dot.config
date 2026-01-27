#!/bin/bash

# 获取 CPU 负载 (User + Sys)
CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -A -o %cpu | awk -v n=$CORE_COUNT '{s+=$1} END {printf "%.0f\n", s/n}')

# 定义图标和颜色
ICON=""
COLOR=0xffffffff 

# 根据负载变色 (超过 30% 变黄，超过 60% 变红)
if [ "$CPU_INFO" -gt 60 ]; then
    COLOR=0xffed8796 # Red
elif [ "$CPU_INFO" -gt 30 ]; then
    COLOR=0xffeed49f # Yellow
fi

sketchybar --set $NAME label="$CPU_INFO%" icon="$ICON" icon.color=$COLOR
