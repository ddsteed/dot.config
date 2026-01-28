#!/bin/bash

CONFIG_FILE="$HOME/.config/aerospace/aerospace.toml"

# 1. 获取显示器信息 (修正变量名为 monitor-name)
MONITOR_NAMES=$(aerospace list-monitors --format "%{monitor-name}")

# 统计数量
MONITOR_COUNT=$(echo "$MONITOR_NAMES" | wc -l | xargs)

# 2. 智能判断逻辑
# 判断是否包含 "Built-in" 或 "内置" (根据您之后反馈的结果，可能还需要微调)
if [ "$MONITOR_COUNT" -eq 1 ] && echo "$MONITOR_NAMES" | grep -qE "Built-in|内置|Retina"; then
    # 笔记本单屏模式 (留出刘海/状态栏高度)
    NEW_GAP=1
else
    # 外接模式 (包括合盖、双屏)
    NEW_GAP=33
fi

# 3. 修改配置 & 重载
sed -i '' "s/outer.top = [0-9]*/outer.top = $NEW_GAP/" "$CONFIG_FILE"
aerospace reload-config

# 4. 通知
osascript -e "display notification \"模式: $([ $NEW_GAP -gt 0 ] && echo '笔记本' || echo '外接') | Gap: $NEW_GAP\" with title \"Aerospace 自动调整\""

