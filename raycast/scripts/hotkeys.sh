#!/bin/bash
# Raycast Script Command: 查看所有快捷键
# 在 Raycast 中添加此脚本后，输入 "hotkeys" 即可查看

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "           macOS 快捷键完整汇总"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. 系统符号快捷键
# ============================================
echo "📌 macOS 系统快捷键"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "  ⇧⌘Space      - Emoji 选择器"
echo "  ⌘Space       - Spotlight 搜索"
echo "  ⌥Space       - Raycast"
echo "  ⇧⌘5          - 截屏工具"
echo "  ⇧⌘4          - 选区截屏"
echo "  ⇧⌘3          - 全屏截屏"
echo "  ⌥⌘Esc        - 强制退出"
echo "  ⌃⌥⌘Esc       - 活动监视器"
echo "  ⌘H           - 隐藏当前应用"
echo "  ⌥⌘H          - 隐藏其他应用"
echo "  ⌘Q           - 退出应用"
echo "  ⇧⌘Q          - 注销"
echo ""

# ============================================
# 2. Raycast 快捷键
# ============================================
echo "🔦 Raycast 快捷键"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ⌥Space       - 打开 Raycast"
echo "  ⌘,           - 打开设置"
echo "  ⌘K           - 命令详情"
echo ""

# ============================================
# 3. BetterDisplay 快捷键
# ============================================
echo "🖥️  BetterDisplay 快捷键"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

bd_plist=~/Library/Preferences/pro.betterdisplay.BetterDisplay.plist

if [ -f "$bd_plist" ]; then
    echo "  已配置的快捷键:"

    plutil -p "$bd_plist" 2>/dev/null | grep "KeyboardShortcuts_" | while IFS='=' read -r key value; do
        key=$(echo "$key" | sed 's/.*"KeyboardShortcuts_//' | sed 's/".*//')
        value=$(echo "$value" | sed 's/^ *"//' | sed 's/"$//')

        if [[ "$value" == *"carbonKeyCode"* ]]; then
            keycode=$(echo "$value" | grep -o '"carbonKeyCode":[0-9]*' | cut -d: -f2)
            modifiers=$(echo "$value" | grep -o '"carbonModifiers":[0-9]*' | cut -d: -f2)

            case $keycode in
                24) key_name="+" ;;
                27) key_name="-" ;;
                8) key_name="C" ;;
                9) key_name="V" ;;
                *) key_name="Key:$keycode" ;;
            esac

            mods=""
            if (( modifiers & 256 )); then mods="⌘$mods"; fi
            if (( modifiers & 2048 )); then mods="⇧$mods"; fi
            if (( modifiers & 512 )); then mods="⌥$mods"; fi
            if (( modifiers & 1024 )); then mods="⌃$mods"; fi

            shortcut="${mods}${key_name}"

            case "$key" in
                brightnessFineUp) desc="亮度微调 +" ;;
                brightnessFineDown) desc="亮度微调 -" ;;
                brightnessUp) desc="亮度 +" ;;
                brightnessDown) desc="亮度 -" ;;
                contrastUp) desc="对比度 +" ;;
                contrastDown) desc="对比度 -" ;;
                volumeUp) desc="音量 +" ;;
                volumeDown) desc="音量 -" ;;
                mute) desc="静音" ;;
                *) desc="$key" ;;
            esac

            echo "    $shortcut - $desc"
        fi
    done
else
    echo "  (未找到配置文件)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 修改快捷键: 系统设置 → 键盘 → 键盘快捷键"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
