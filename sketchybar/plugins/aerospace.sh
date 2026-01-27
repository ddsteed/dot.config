#!/bin/bash

# 加载图标映射
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

SID=$1

# 1. 获取 App 列表
APPS=$(aerospace list-windows --workspace "$SID" --format "%{app-name}" | sort -u)

# 2. 判断可见性
if [ -n "$APPS" ] || [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
    DRAWING="on"
else
    DRAWING="off"
fi

# 3. 样式逻辑 (颜色调整)
if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
    # 激活：纯白色
    COLOR=0xffffffff 
else
    # 非激活：亮灰色 (比之前亮了很多，在黑色背景下也能看清)
    # 如果觉得还不够亮，可以改成 0xffcdd6f4
    COLOR=0xffa6adc8 
fi

# 4. 图标映射
ICON_STR=""
if [ -n "$APPS" ]; then
    while read -r app; do
        __icon_map "$app"
        # 图标之间增加空格
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
