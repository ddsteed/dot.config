#!/bin/bash

# ==========================================================
# SketchyBar Weather Plugin (直连定位版)
# ==========================================================

NAME="${NAME:-weather}"
LOG_FILE="/tmp/weather.log"
CACHE_FILE="/tmp/weather_cache.sh"

if [ -x "/opt/homebrew/bin/sketchybar" ]; then SB_CMD="/opt/homebrew/bin/sketchybar"; else SB_CMD=$(which sketchybar); fi

# ==========================================================
# 1. 获取真实位置 (关键修改)
# ==========================================================

# --noproxy "*" : 强制 curl 不走任何代理，直接连接
# 这样 ip-api 看到的就是您真实的本地 IP，而不是 VPN 的出口 IP
LOC_DATA=$(curl -s --noproxy "*" --max-time 20 "http://ip-api.com/json/")

# 提取经纬度
LAT=$(echo "$LOC_DATA" | grep -o '"lat":[0-9.-]*' | head -n 1 | cut -d: -f2)
LON=$(echo "$LOC_DATA" | grep -o '"lon":[0-9.-]*' | head -n 1 | cut -d: -f2)

# 如果直连失败 (有些公司内网可能必须走代理)，尝试不带 noproxy 再试一次
if [[ ! "$LAT" =~ ^[0-9.-]+$ ]]; then
    LOC_DATA=$(curl -s --max-time 20 "http://ip-api.com/json/")
    LAT=$(echo "$LOC_DATA" | grep -o '"lat":[0-9.-]*' | head -n 1 | cut -d: -f2)
    LON=$(echo "$LOC_DATA" | grep -o '"lon":[0-9.-]*' | head -n 1 | cut -d: -f2)
fi

# 最后的保底 (默认成都)
if [[ ! "$LAT" =~ ^[0-9.-]+$ ]]; then
    LAT="30.57"; LON="104.06"
fi

# ==========================================================
# 2. 获取天气 (这个可以走 VPN，不影响)
# ==========================================================
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current_weather=true"
DATA=$(curl -s --max-time 20 "$URL")

# 解析数据
RAW_TEMP=$(echo "$DATA" | grep -oE '"temperature":[0-9.-]+' | cut -d: -f2)
CODE=$(echo "$DATA" | grep -oE '"weathercode":[0-9]+' | cut -d: -f2)

# ==========================================================
# 3. 缓存逻辑 (带颜色区分)
# ==========================================================
if [ -n "$RAW_TEMP" ]; then
    # --- 成功获取 (数据是新鲜的) ---
    TEMP=$(printf "%.0f°C" "$RAW_TEMP")
    
    case "$CODE" in
        0) ICON=""; COLOR=0xfff9e2af ;;
        1|2|3) ICON=""; COLOR=0xff9399b2 ;;
        # ... (其他 case 不变) ...
        *) ICON=""; COLOR=0xff9399b2 ;;
    esac
    
    # 正常颜色 (文字白色，图标彩色)
    LABEL_COLOR=0xffffffff
    
    # 写入缓存
    echo "TEMP='$TEMP'" > "$CACHE_FILE"
    echo "ICON='$ICON'" >> "$CACHE_FILE"
    echo "COLOR='$COLOR'" >> "$CACHE_FILE"

else
    # --- 获取失败 (数据是陈旧的) ---
    echo "获取失败，读取缓存..." >> $LOG_FILE
    
    if [ -f "$CACHE_FILE" ]; then
        source "$CACHE_FILE"
        
        # 【关键修改】将颜色变暗
        # 0xff5c5f77 是暗灰色
        # 或者用 0x88ffffff (半透明白色)
        COLOR=0xff5c5f77       # 图标变暗
        LABEL_COLOR=0xff5c5f77 # 文字变暗
        
    else
        # 彻底没数据
        TEMP="Offline"
        ICON=""
        COLOR=0xffed8796
        LABEL_COLOR=0xffed8796
    fi
fi

# ==========================================================
# 4. 更新 UI
# ==========================================================
# 记得加上 label.color=$LABEL_COLOR
$SB_CMD --set "$NAME" \
        icon="$ICON" \
        icon.color=$COLOR \
        label="$TEMP" \
        label.color=$LABEL_COLOR \
        label.padding_left=10

