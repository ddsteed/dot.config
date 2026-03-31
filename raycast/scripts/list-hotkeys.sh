#!/bin/bash
# macOS 快捷键完整列表

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "           macOS 快捷键完整汇总"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================
# 1. 系统符号快捷键
# ============================================
echo "📌 macOS 系统快捷键"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 从 defaults 读取并解析
defaults read com.apple.symbolichotkeys AppleSymbolicHotkeys 2>/dev/null | plutil -p - | grep -A 5 '"enabled" => "1"' | grep -B 1 'parameters' | grep -E '"[0-9]+" =>|parameters' | while IFS= read -r line; do
    if echo "$line" | grep -q '"[0-9]\+" =>'; then
        id=$(echo "$line" | grep -o '[0-9]\+')
    fi
    if echo "$line" | grep -q 'parameters'; then
        case $id in
            60) echo "  [60] 选择前一个输入源: Shift+Cmd+Space" ;;
            61) echo "  [61] 选择下一个输入源: Ctrl+Cmd+Space" ;;
            64) echo "  [64] 显示表情符号: Shift+Cmd+Space ✓ (已修改)" ;;
            79) echo "  [79] Mission Control" ;;
            80) echo "  [80] 显示桌面" ;;
            81) echo "  [81] 显示所有窗口" ;;
            82) echo "  [82] App Exposé" ;;
            36) echo "  [36] 输入法切换相关" ;;
            37) echo "  [37] 输入法切换相关" ;;
            *) echo "  [$id] 其他系统快捷键" ;;
        esac
    fi
done

echo ""
echo "常用系统快捷键:"
echo "  ⌘Space       - Spotlight 搜索"
echo "  ⌥Space       - Raycast"
echo "  ⇧⌘5          - 截屏"
echo "  ⇧⌘4          - 选区截屏"
echo "  ⇧⌘3          - 全屏截屏"
echo "  ⌃⌘Space      - 原系统 Emoji (已冲突)"
echo "  ⇧⌘Space      - 新 Emoji 快捷键"
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
echo "  主快捷键: ⌥Space (Option+Space)"
echo ""
echo "  内置命令快捷键 (可在设置中查看):"
echo "  - Search Emoji: ⇧⌘Space (需要设置)"
echo "  - Clipboard History: ⌘⇧C (需要设置)"
echo "  - Snippets: ⌘⇧S (需要设置)"
echo ""

# ============================================
# 3. BetterDisplay 快捷键
# ============================================
echo "🖥️  BetterDisplay 快捷键"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 读取 BetterDisplay 配置
bd_plist=~/Library/Preferences/pro.betterdisplay.BetterDisplay.plist

if [ -f "$bd_plist" ]; then
    echo "  已配置的快捷键:"

    # 使用 grep 查找所有快捷键配置
    plutil -p "$bd_plist" 2>/dev/null | grep "KeyboardShortcuts_" | while IFS='=' read -r key value; do
        # 清理格式
        key=$(echo "$key" | sed 's/.*"KeyboardShortcuts_//' | sed 's/".*//')
        value=$(echo "$value" | sed 's/^ *"//' | sed 's/"$//')

        # 解码快捷键
        if [[ "$value" == *"carbonKeyCode"* ]]; then
            # 提取键码和修饰符
            keycode=$(echo "$value" | grep -o '"carbonKeyCode":[0-9]*' | cut -d: -f2)
            modifiers=$(echo "$value" | grep -o '"carbonModifiers":[0-9]*' | cut -d: -f2)

            # 解码键码
            case $keycode in
                24) key_name="+" ;;
                27) key_name="-" ;;
                0) key_name="A" ;;
                1) key_name="S" ;;
                2) key_name="D" ;;
                8) key_name="C" ;;
                9) key_name="V" ;;
                49) key_name="Space" ;;
                122) key_name="F1" ;;
                123) key_name="←" ;;
                124) key_name="→" ;;
                125) key_name="↓" ;;
                126) key_name="↑" ;;
                *) key_name="Key:$keycode" ;;
            esac

            # 解码修饰符 (Carbon 格式)
            mods=""
            if (( modifiers & 256 )); then mods="⌘$mods"; fi      # cmdKey
            if (( modifiers & 2048 )); then mods="⇧$mods"; fi    # shiftKey
            if (( modifiers & 512 )); then mods="⌥$mods"; fi     # optionKey
            if (( modifiers & 1024 )); then mods="⌃$mods"; fi    # controlKey

            # 翻转顺序 (修饰符在前面)
            shortcut="${mods}${key_name}"

            # 中文描述
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
echo "  默认建议快捷键:"
echo "    ⌥⌥=        - 增加亮度"
echo "    ⌥⌥-        - 减少亮度"
echo ""

# ============================================
# 4. 其他应用
# ============================================
echo "📱 其他应用快捷键"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Ghostty
if [ -f ~/Library/Preferences/com.mitchellh.ghostty.plist ]; then
    echo "  Ghostty (终端):"
    echo "    ⌘T         - 新标签页"
    echo "    ⌘W         - 关闭标签页"
    echo "    ⌘↵         - 全屏"
fi

# Shadowrocket
if [ -f ~/Library/Preferences/com.liguangming.Shadowrocket.plist ]; then
    echo "  Shadowrocket:"
    echo "    (查看应用内设置)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📂 查看完整快捷键设置:"
echo "   系统设置 → 键盘 → 键盘快捷键"
echo "   各应用内 → Settings/Preferences → Keyboard/Shortcuts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
