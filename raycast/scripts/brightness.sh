#!/bin/bash
# BetterDisplay Brightness Control for Raycast
# 需要 BetterDisplay 安装并启用 DDC 控制

# 获取参数
ACTION="$1"  # up, down, set
VALUE="$2"   # 步长或目标值 (0-100)

# 默认步长
STEP=${VALUE:-5}

# 使用 BetterDisplay 的命令行工具（如果支持）
if command -v /Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay &> /dev/null; then
    case "$ACTION" in
        up)
            osascript -e 'tell application "BetterDisplay" to increment brightness by '"$STEP"
            ;;
        down)
            osascript -e 'tell application "BetterDisplay" to decrement brightness by '"$STEP"
            ;;
        set)
            osascript -e 'tell application "BetterDisplay" to set brightness to '"$VALUE"
            ;;
    esac
else
    # 备选方案：使用 DDCctl（需要单独安装）
    # brew install ddcctl
    echo "请安装 BetterDisplay 或使用 ddcctl"
    exit 1
fi
