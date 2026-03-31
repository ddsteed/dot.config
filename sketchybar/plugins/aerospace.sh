#!/bin/bash
# ==============================================================
# AeroSpace 工作区条目渲染器 (Geek Glass 风格)
# ==============================================================
# @author    Hao Feng (F1)
# @file      aerospace.sh
# @desc      渲染 AeroSpace 工作区条目，显示工作区中的应用图标
#
# 功能实现：
#   1. 高亮显示当前聚焦的工作区（下划线效果）
#   2. 隐藏没有（可见）应用的工作区
#   3. 支持工作区数量 >= 5（需在 sketchybarrc 中创建足够多的条目）
#   4. 显示工作区内所有应用的图标
#
# 调用方式：
#   script="$PLUGIN_DIR/aerospace.sh $sid"
#   其中 $sid 是工作区编号 (1-10)
#
# 环境变量：
#   $NAME - SketchyBar 自动传入的条目名称 (如 "space.1")
#   $FOCUSED_WORKSPACE - AeroSpace 传入的聚焦工作区编号（如果有）
#   $SENDER - 触发此脚本的事件名称
#
# @version   1.0.1 (2026-03-19)
#            - 统一版本格式
#            1.0.0 (2025-02-05)
#            - 初始版本，集成 AeroSpace 工作区管理
#            - 实现应用图标映射和显示/隐藏逻辑
# ==============================================================

# --------------------------------------------------------------
# 加载图标映射函数
# --------------------------------------------------------------
# icon_map.sh 提供 __icon_map() 函数，用于将应用名称映射到图标
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

# --------------------------------------------------------------
# 加载主题配置 (如果存在)
# --------------------------------------------------------------
THEME_FILE="$HOME/.config/sketchybar/theme.sh"
if [[ -f "$THEME_FILE" ]]; then
    source "$THEME_FILE"
fi

# --------------------------------------------------------------
# 颜色变量定义 (带默认值回退)
# --------------------------------------------------------------
# FG: 前景色，用于工作区编号和标签
FG="${FG:-0xFFEDEDED}"
# ACCENT: 强调色，用于聚焦的工作区
WORKSPACE_FOCUSED="${WORKSPACE_FOCUSED:-0xFF7EDEFF}"
# WORKSPACE_INACTIVE: 非聚焦工作区的颜色
WORKSPACE_INACTIVE="${WORKSPACE_INACTIVE:-0xFFD0D0D0}"

# --------------------------------------------------------------
# 获取当前工作区编号
# --------------------------------------------------------------
# 从命令行参数获取，或者从 $NAME 变量提取
# $NAME 格式如 "space.1"，我们提取 "1" 部分
SID="$1"

# --------------------------------------------------------------
# 获取聚焦的工作区编号
# --------------------------------------------------------------
# 优先使用 AeroSpace 传入的 FOCUSED_WORKSPACE 环境变量
# 如果没有，则直接查询 AeroSpace 命令
if [[ -n "${FOCUSED_WORKSPACE:-}" ]]; then
    # 去除回车符（Windows 风格换行符）
    FOCUSED_WORKSPACES="$(printf '%s\n' "$FOCUSED_WORKSPACE" | tr -d '\r')"
else
    # 调用 aerospace 命令获取当前聚焦的工作区
    # --focused: 只显示聚焦的工作区
    FOCUSED_WORKSPACES="$(aerospace list-workspaces --focused 2>/dev/null | tr -d '\r')"
fi

# --------------------------------------------------------------
# 获取当前工作区中的所有应用
# --------------------------------------------------------------
# --workspace: 指定工作区编号
# --format: 输出格式，%{app-name} 表示只输出应用名称
# 2>/dev/null: 忽略错误输出
# sort -u: 去重，确保每个应用只出现一次
APPS="$(aerospace list-windows --workspace "$SID" --format "%{app-name}" 2>/dev/null | sort -u)"

# --------------------------------------------------------------
# 构建图标字符串并检测是否有可见应用
# --------------------------------------------------------------
# ICON_STR: 最终显示的图标字符串，如 "   "
# HAS_VISIBLE_APPS: 标记是否有可见应用 (0=无, 1=有)
ICON_STR=""
HAS_VISIBLE_APPS=0

if [[ -n "$APPS" ]]; then
    # 逐行读取应用列表
    while read -r app; do
        # 跳过空行
        [[ -z "$app" ]] && continue

        # 调用图标映射函数
        __icon_map "$app"

        # 如果图标为空，说明该应用应该被隐藏（如 Finder）
        [[ -z "${icon_result:-}" ]] && continue

        # 标记有可见应用
        HAS_VISIBLE_APPS=1

        # 拼接图标字符串（两个空格分隔）
        if [[ -z "$ICON_STR" ]]; then
            ICON_STR="$icon_result"
        else
            ICON_STR="$ICON_STR  $icon_result"
        fi
    done <<< "$APPS"
fi

# --------------------------------------------------------------
# 判断当前工作区是否聚焦
# --------------------------------------------------------------
# grep -qx: 完全匹配整行
if echo "$FOCUSED_WORKSPACES" | grep -qx "$SID"; then
    IS_FOCUSED=1
else
    IS_FOCUSED=0
fi

# --------------------------------------------------------------
# 决定是否绘制此工作区条目
# --------------------------------------------------------------
# 绘制规则：
# - 如果工作区聚焦，总是显示（即使为空，方便用户知道当前在哪）
# - 如果工作区有可见应用，显示之
# - 否则，隐藏（保持界面简洁）
if [[ "$IS_FOCUSED" -eq 1 || "$HAS_VISIBLE_APPS" -eq 1 ]]; then
    DRAWING="on"
else
    DRAWING="off"
fi

# --------------------------------------------------------------
# 根据聚焦状态设置样式
# --------------------------------------------------------------
if [[ "$IS_FOCUSED" -eq 1 ]]; then
    # 聚焦状态：使用强调色，显示下划线
    ICON_COLOR="$WORKSPACE_FOCUSED"           # 青色高亮
    LABEL_COLOR="$FG"              # 白色文本
    BG_DRAWING="on"                # 开启背景绘制（下划线）
    BG_COLOR="$WORKSPACE_FOCUSED"             # 下划线颜色
    BG_HEIGHT=3                    # 下划线高度
    BG_RADIUS=2                    # 下划线圆角
    BG_Y_OFFSET=12                 # 下划线垂直偏移
else
    # 非聚焦状态：使用静默色，无下划线
    ICON_COLOR="$WORKSPACE_INACTIVE"  # 灰色
    LABEL_COLOR="$WORKSPACE_INACTIVE"
    BG_DRAWING="off"                  # 关闭背景绘制
    BG_COLOR=0x00000000               # 透明
    BG_HEIGHT=0
    BG_RADIUS=0
    BG_Y_OFFSET=0
fi

# --------------------------------------------------------------
# 更新 SketchyBar 条目
# --------------------------------------------------------------
# --set $NAME: 更新当前条目
# drawing: 是否绘制此条目
# icon: 工作区编号
# icon.color: 图标颜色
# label: 应用图标字符串
# label.color: 标签颜色
# background.*: 下划线样式
sketchybar --set "$NAME" \
           drawing="$DRAWING" \
           icon="$SID" \
           icon.color="$ICON_COLOR" \
           label="$ICON_STR" \
           label.color="$LABEL_COLOR" \
           background.drawing="$BG_DRAWING" \
           background.color="$BG_COLOR" \
           background.height="$BG_HEIGHT" \
           background.corner_radius="$BG_RADIUS" \
           background.y_offset="$BG_Y_OFFSET"
