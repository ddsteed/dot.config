#!/bin/bash
# ==============================================================
# 输入法显示插件 (Geek Glass)
# ==============================================================
# @author    Hao Feng (F1)
# @file      input.sh
# @desc      显示当前输入法状态（中文/英文）
#
# 输入法标识：
#   - Ψ (或空白): Squirrel/Rime 中文输入
#   - A: ABC 英文输入
#   - 中 🇨🇳: 搜狗输入法
#   - ??: 未知输入法
#
# 技术实现：
#   使用 JXA (JavaScript for Automation) 通过 osascript
#   调用 Carbon 框架获取当前输入源 ID
#
# 触发事件：input_change (系统输入法切换通知)
#
# @version   1.0.1 (2026-03-19)
#            - 调试日志默认禁用（减少 I/O 开销）
#            1.0.0 (2025-03-04)
#            - 初始版本，支持 Squirrel/Rime 检测
#            - 添加调试日志支持
# ==============================================================

# --------------------------------------------------------------
# 调试日志配置
# --------------------------------------------------------------
# 默认禁用日志。如需启用调试，取消下面这行的注释：
#LOG_FILE="/tmp/input_debug.log"
LOG_FILE="${LOG_FILE:-/dev/null}"

# --------------------------------------------------------------
# 记录脚本开始运行的时间和触发者（仅在调试模式下）
# --------------------------------------------------------------
# $SENDER: SketchyBar 传入的事件触发者
if [[ "$LOG_FILE" != "/dev/null" ]]; then
  echo "--- $(date '+%H:%M:%S') 触发者: ${SENDER:-手动运行} ---" >> "$LOG_FILE"
fi

# --------------------------------------------------------------
# 1. 确定目标组件名称
# --------------------------------------------------------------
# 如果 SketchyBar 没传名字进来，默认为 "input"
TARGET_NAME="${NAME:-input}"
if [[ "$LOG_FILE" != "/dev/null" ]]; then
  echo "目标组件: [$TARGET_NAME]" >> "$LOG_FILE"
fi

# --------------------------------------------------------------
# 2. 获取输入法 ID
# --------------------------------------------------------------
# 使用 JXA (JavaScript for Automation) 代码
# -l JavaScript: 指定使用 JavaScript
# ObjC.import('Carbon'): 导入 Carbon 框架
# TISCopyCurrentKeyboardInputSource(): 获取当前输入源
# kTISPropertyInputSourceID: 输入源 ID 属性
CURRENT_SOURCE=$(osascript -l JavaScript -e "
function run() {
  ObjC.import('Carbon');
  var source = \$.TISCopyCurrentKeyboardInputSource();
  var id = \$.TISGetInputSourceProperty(source, \$.kTISPropertyInputSourceID);
  var nsString = ObjC.castRefToObject(id);
  return nsString.js;
}" 2>/dev/null)

if [[ "$LOG_FILE" != "/dev/null" ]]; then
  echo "获取到的 ID: [$CURRENT_SOURCE]" >> "$LOG_FILE"
fi

# --------------------------------------------------------------
# 3. 根据输入法 ID 匹配显示内容
# --------------------------------------------------------------
# case 语句支持模式匹配
# *"Squirrel"*: 包含 "Squirrel" 字符串
# |: 或运算符
case "$CURRENT_SOURCE" in
    # Squirrel / Rime 中文输入
    *"Squirrel"* | *"rime"*)
        LABEL="Ψ"      # Psi 符号
        ICON=""        # 不显示图标
        #ICON="🐹"     # 备选：仓鼠图标
        #ICON=""     # 备选：兔子图标
        ;;
    # ABC 英文输入
    *"ABC"* | *"US"* | *"keylayout.ABC"*)
        LABEL="A"      # 大写字母 A
        ICON=""        # 不显示图标
        #ICON="🇺🇸"    # 备选：美国国旗
        ;;
    # 搜狗输入法
    *"sogou"*)
        LABEL="中"     # 中文
        ICON="🇨🇳"    # 中国国旗
        ;;
    # 未知输入法
    *)
        LABEL="??"     # 问号
        ICON="❓"      # 问号图标
        ;;
esac

if [[ "$LOG_FILE" != "/dev/null" ]]; then
  echo "准备设置: 图标=[$ICON] 标签=[$LABEL]" >> "$LOG_FILE"
fi

# --------------------------------------------------------------
# 4. 执行更新并记录结果
# --------------------------------------------------------------
# 捕获 sketchybar 的返回信息，查看是否有报错
# 2>&1: 同时捕获标准输出和标准错误
OUTPUT=$(sketchybar --set "$TARGET_NAME" icon="$ICON" label="$LABEL" 2>&1)

# 检查退出状态码（仅在调试模式下记录）
if [[ "$LOG_FILE" != "/dev/null" ]]; then
  if [ $? -eq 0 ]; then
    echo "更新成功" >> "$LOG_FILE"
  else
    echo "更新失败! 错误信息: $OUTPUT" >> "$LOG_FILE"
  fi
  echo "------------------------------------------------" >> "$LOG_FILE"
fi
