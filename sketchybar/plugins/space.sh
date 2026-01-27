#!/bin/bash

# 加载图标映射函数
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

if [ "$SENDER" = "space_windows_change" ]; then
  # 获取当前 Space 下的所有窗口所属的 App 名字
  # aerospace list-windows --workspace $SID --format %{app-name} (如果你用的是 Aerospace)
  # 或者 yabai -m query --windows --space $SID (如果你用的是 yabai)
  # SketchyBar 自带的方法：$INFO 包含了 app 列表
  
  # 这里的 $INFO 变量由 SketchyBar 在触发 space_windows_change 时自动传入
  # 它是一个 JSON 数组，包含该 space 下所有 app 的名字
  APPS=$(echo "$INFO" | jq -r '.apps[]')

  ICON_STR=""
  if [ "$APPS" != "" ]; then
    while read -r app; do
      __icon_map "$app"
      ICON_STR="$ICON_STR $icon_result"
    done <<< "$APPS"
  fi

  sketchybar --set $NAME icon.label="$ICON_STR"
fi

