#!/bin/bash

CONFIG_FILE="$HOME/.config/aerospace/aerospace.toml"

# === 1. 获取显示器信息 ===
# 获取所有显示器的名称
MONITOR_NAMES=$(aerospace list-monitors --format "%{monitor-name}")
# 统计显示器数量 (去除空白符)
MONITOR_COUNT=$(echo "$MONITOR_NAMES" | grep -v "^$" | wc -l | xargs)

# === 2. 智能判断逻辑 ===
# 定义笔记本屏幕的特征关键词
INTERNAL_KEYWORDS="Built-in|内置|Retina|Laptop"

# 默认设置为外接模式
MODE_NAME="外接/多屏"
NEW_GAP=30

# 只有当：显示器数量为 1 且 该显示器名称包含内屏关键词时，才判定为笔记本模式
if [ "$MONITOR_COUNT" -eq 1 ]; then
    if echo "$MONITOR_NAMES" | grep -qE "$INTERNAL_KEYWORDS"; then
        MODE_NAME="笔记本单屏"
        NEW_GAP=1  # 或者你想要的 1
    fi
fi

# === 3. 修改配置 & 重载 ===
# 使用 sed 修改 aerospace.toml 中的 outer.top 值
# 确保你的配置文件中有一行写着 outer.top = ...
sed -i '' "s/outer.top = [0-9]*/outer.top = $NEW_GAP/" "$CONFIG_FILE"

# 重载配置
aerospace reload-config

# === 4. 发送准确通知 ===
# 直接使用上面定义好的 MODE_NAME 变量，避免再次逻辑判断出错
# osascript -e "display notification \"模式: $MODE_NAME | Gap: $NEW_GAP\" with title \"Aerospace 自动调整\""

# === 5. (可选) 调试输出 ===
# 如果运行有问题，在终端手动执行脚本可以看到下面的输出
echo "--------------------------------"
echo "检测到的显示器数量: $MONITOR_COUNT"
echo "检测到的显示器名称: "
echo "$MONITOR_NAMES"
echo "--------------------------------"
echo "判定结果 -> 模式: $MODE_NAME, Gap: $NEW_GAP"

