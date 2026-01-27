#!/bin/bash

# 使用 memory_pressure 获取内存压力 (更符合 Apple Silicon 的逻辑)
# 这是一个近似值，代表系统内存的紧张程度
MEMORY_PRESSURE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{ print 100 - $5 }')

ICON=""
COLOR=0xffffffff

# 变色逻辑
if [ "$MEMORY_PRESSURE" -gt 70 ]; then
    COLOR=0xffed8796 # Red
elif [ "$MEMORY_PRESSURE" -gt 30 ]; then
    COLOR=0xffeed49f # Yellow
fi

sketchybar --set $NAME label="$MEMORY_PRESSURE%" icon="$ICON" icon.color=$COLOR
