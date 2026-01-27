#!/bin/bash

# 加载图标映射
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

SID=$1

# ==============================================================
# 核心修复：主动获取当前激活的 Workspace ID
# ==============================================================
# 不再依赖 $FOCUSED_WORKSPACE 环境变量，而是直接问 Aerospace
# 这样无论是什么事件触发 (关闭窗口、切换 App)，都能正确获得高亮状态
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# 1. 获取该 Workspace 下的 App 列表
APPS=$(aerospace list-windows --workspace "$SID" --format "%{app-name}" | sort -u)

# 2. 判断可见性
if [ -n "$APPS" ] || [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
    DRAWING="on"
else
    DRAWING="off"
fi

# 3. 样式逻辑
if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
    # 激活：纯白色
    COLOR=0xffffffff 
else
    # 非激活：亮灰色
    COLOR=0xffa6adc8 
fi

# 4. 图标映射
ICON_STR=""
if [ -n "$APPS" ]; then
    while read -r app; do
        __icon_map "$app"
        if [ -n "$icon_result" ]; then
            ICON_STR="$ICON_STR $icon_result "
        fi
    done <<< "$APPS"
fi

# 5. 更新 SketchyBar
sketchybar --set $NAME \
           drawing=$DRAWING \
           background.drawing=off \
           label.color=$COLOR \
           icon.color=$COLOR \
           icon="$SID" \
           label="$ICON_STR"

