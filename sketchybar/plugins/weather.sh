#!/bin/bash

# ==========================================================
# SketchyBar Weather Plugin (数字精准过滤版)
# ==========================================================

NAME="${NAME:-weather}"
LOG_FILE="/tmp/weather.log"

# 查找 sketchybar
if [ -x "/opt/homebrew/bin/sketchybar" ]; then SB_CMD="/opt/homebrew/bin/sketchybar"; else SB_CMD=$(which sketchybar); fi

# ==========================================================
# 1. 获取经纬度 (带保底)
# ==========================================================
LOC_DATA=$(curl -s --max-time 3 "http://ip-api.com/json/")
LAT=$(echo "$LOC_DATA" | grep -o '"lat":[0-9.-]*' | head -n 1 | cut -d: -f2)
LON=$(echo "$LOC_DATA" | grep -o '"lon":[0-9.-]*' | head -n 1 | cut -d: -f2)

# 如果提取失败，强制使用成都坐标
if [[ ! "$LAT" =~ ^[0-9.-]+$ ]]; then
    LAT="30.57"
    LON="104.06"
fi

# ==========================================================
# 2. 获取天气
# ==========================================================
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current_weather=true"
DATA=$(curl -s "$URL")

# ==========================================================
# 3. 解析温度 (核心修复)
# ==========================================================
# 使用 grep -oE '"temperature":[0-9.-]+'
# 解释：
# 1. 匹配 "temperature":
# 2. 紧接着必须是数字 [0-9] 或小数点/负号
# 这样就能自动跳过 "temperature":"°C" (因为它包含引号，不是纯数字)
RAW_TEMP=$(echo "$DATA" | grep -oE '"temperature":[0-9.-]+' | cut -d: -f2)

# 同理匹配 weathercode
CODE=$(echo "$DATA" | grep -oE '"weathercode":[0-9]+' | cut -d: -f2)

# 格式化温度
if [ -n "$RAW_TEMP" ]; then
    # 四舍五入，并加上单位
    TEMP=$(printf "%.0f°C" "$RAW_TEMP")
else
    # 如果还是失败，说明 Open-Meteo 彻底没返回数字
    TEMP="?°C"
fi

# ==========================================================
# 4. 图标映射
# ==========================================================
case "$CODE" in
    0) ICON=""; COLOR=0xfff9e2af ;;
    1|2|3) ICON=""; COLOR=0xff9399b2 ;;
    45|48) ICON="🌫"; COLOR=0xff9399b2 ;;
    51|53|55|61|63|65|80|81|82) ICON=""; COLOR=0xff8aadf4 ;;
    71|73|75|77|85|86) ICON=""; COLOR=0xffffffff ;;
    95|96|99) ICON=""; COLOR=0xffed8796 ;;
    *) ICON=""; COLOR=0xff9399b2 ;;
esac

# ==========================================================
# 5. 更新 UI
# ==========================================================
# 增加 label.padding_left=10 来制造间距
$SB_CMD --set "$NAME" icon="$ICON" icon.color=$COLOR label="$TEMP" label.padding_left=10


