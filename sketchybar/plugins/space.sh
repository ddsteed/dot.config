#!/bin/bash
# ==============================================================
# macOS 空间 (Space) 显示插件
# ==============================================================
# @author    Hao Feng (F1)
# @file      space.sh
# @desc      显示当前 macOS Space 中的应用图标
#
# 与 aerospace.sh 的区别：
#   - aerospace.sh: 用于 AeroSpace 窗口管理器的工作区
#   - space.sh: 用于 macOS 原生 Space（虚拟桌面）
#
# 触发事件：space_windows_change (空间内窗口变化时)
#
# @note      此配置中主要使用 aerospace.sh，此文件为备用
#
# @version   1.0.0 (2025-02-04)
#            - 初始版本，支持原生 Space 应用显示
# ==============================================================

# --------------------------------------------------------------
# 加载图标映射函数
# --------------------------------------------------------------
# icon_map.sh 提供 __icon_map() 函数
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

# --------------------------------------------------------------
# 处理空间窗口变化事件
# --------------------------------------------------------------
# $SENDER: SketchyBar 传入的事件名称
# $INFO: SketchyBar 传入的应用列表 (JSON 格式)
if [ "$SENDER" = "space_windows_change" ]; then
  # ----------------------------------------------------------
  # 获取当前 Space 下的所有窗口所属的 App 名字
  # ----------------------------------------------------------
  # $INFO 是由 SketchyBar 在触发 space_windows_change 时自动传入的
  # 它是一个 JSON 数组，包含该 space 下所有 app 的名字
  #
  # 如果你使用 yabai：
  #   yabai -m query --windows --space $SID
  #
  # 如果你使用 AeroSpace：
  #   aerospace list-windows --workspace $SID --format %{app-name}
  #
  # 这里使用 SketchyBar 内置的 $INFO 变量（推荐）
  APPS=$(echo "$INFO" | jq -r '.apps[]')

  # ----------------------------------------------------------
  # 构建图标字符串
  # ----------------------------------------------------------
  ICON_STR=""
  if [ "$APPS" != "" ]; then
    # 逐行读取应用列表
    while read -r app; do
      # 调用图标映射函数
      __icon_map "$app"

      # 跳过空图标（应该隐藏的应用，如 Finder）
      [ -z "$icon_result" ] && continue

      # 拼接图标字符串（两个空格分隔）
      if [ -z "$ICON_STR" ]; then
        ICON_STR="$icon_result"
      else
        ICON_STR="$ICON_STR  $icon_result"
      fi
    done <<< "$APPS"
  fi

  # ----------------------------------------------------------
  # 更新 SketchyBar 条目
  # ----------------------------------------------------------
  # $NAME: 当前条目名称
  # icon.label: 图标标签（使用 icon.label 而非 label）
  sketchybar --set $NAME icon.label="$ICON_STR"
fi
