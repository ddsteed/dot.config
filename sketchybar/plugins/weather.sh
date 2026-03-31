#!/bin/bash
# ==============================================================
# 天气显示插件 (Geek Glass)
# ==============================================================
# @author    Hao Feng (F1)
# @file      weather.sh
# @desc      显示当前天气信息（温度 + 天气图标）
#
# 功能说明：
#   - 使用 Open-Meteo API 获取天气数据（免费，无需 API Key）
#   - 使用 ip-api 进行 IP 地理定位
#   - 内置缓存机制，网络故障时使用缓存数据
#   - 默认位置回退：成都 (30.57, 104.06)
#
# 天气图标映射：
#   代码 0: 晴天 
#   代码 1-3: 多云/阴天 
#   代码 45-48: 雾 󰖑
#   代码 51-57: 毛毛雨/雨 
#   代码 61-67: 雨 
#   代码 71-77: 雪 
#   代码 80-82: 阵雨 
#   代码 95-99: 雷暴 
#
# WMO 天气代码：
#   https://open-meteo.com/en/docs
#
# 更新频率：1200 秒 (20 分钟)
#
# @version   1.0.1 (2026-03-19)
#            - 统一版本格式
#            1.0.0 (2025-03-04)
#            - 初始版本，集成 Open-Meteo 天气 API
#            - 添加缓存和网络故障回退机制
# ==============================================================

# --------------------------------------------------------------
# 配置变量
# --------------------------------------------------------------
NAME="${NAME:-weather}"                              # 条目名称
CACHE_FILE="/tmp/weather_cache.sh"                   # 缓存文件路径

# --------------------------------------------------------------
# 查找 sketchybar 可执行文件
# --------------------------------------------------------------
if [ -x "/opt/homebrew/bin/sketchybar" ]; then
  SB_CMD="/opt/homebrew/bin/sketchybar"
else
  SB_CMD="$(command -v sketchybar)"
fi

# --------------------------------------------------------------
# 加载主题配置 (如果存在)
# --------------------------------------------------------------
THEME_FILE="$HOME/.config/sketchybar/theme.sh"
if [[ -f "$THEME_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$THEME_FILE"
fi

# --------------------------------------------------------------
# 默认颜色回退 (当主题文件不存在时)
# --------------------------------------------------------------
FG="${FG:-0xFFEDEDED}"          # 前景色
MUTED="${MUTED:-0xFF8A8F98}"    # 静默色
ACCENT="${ACCENT:-0xFF1E7AA6}"  # 强调色（深青色）

# --------------------------------------------------------------
# 1) 地理定位 (优先尝试直连，失败则使用代理)
# --------------------------------------------------------------
# 使用 ip-api.com 获取位置信息
# --noproxy "*": 跳过代理设置
# --max-time 12: 12 秒超时
LOC_DATA=$(curl -s --noproxy "*" --max-time 12 "http://ip-api.com/json/")

# 提取经纬度
LAT=$(echo "$LOC_DATA" | grep -o '"lat":[0-9.-]*' | head -n 1 | cut -d: -f2)
LON=$(echo "$LOC_DATA" | grep -o '"lon":[0-9.-]*' | head -n 1 | cut -d: -f2)

# 如果直连失败，尝试使用代理
if [[ ! "$LAT" =~ ^[0-9.-]+$ ]]; then
  LOC_DATA=$(curl -s --max-time 12 "http://ip-api.com/json/")
  LAT=$(echo "$LOC_DATA" | grep -o '"lat":[0-9.-]*' | head -n 1 | cut -d: -f2)
  LON=$(echo "$LOC_DATA" | grep -o '"lon":[0-9.-]*' | head -n 1 | cut -d: -f2)
fi

# 最终回退位置：成都
if [[ ! "$LAT" =~ ^[0-9.-]+$ ]]; then
  LAT="30.57"; LON="104.06"
fi

# --------------------------------------------------------------
# 2) 获取天气数据
# --------------------------------------------------------------
# 使用 Open-Meteo API (免费，无需注册)
# latitude=纬度, longitude=经度
# current_weather=true: 获取当前天气
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current_weather=true"
DATA=$(curl -s --max-time 12 "$URL")

# 提取温度和天气代码
RAW_TEMP=$(echo "$DATA" | grep -oE '"temperature":[0-9.-]+' | head -n 1 | cut -d: -f2)
CODE=$(echo "$DATA" | grep -oE '"weathercode":[0-9]+' | head -n 1 | cut -d: -f2)

# --------------------------------------------------------------
# 3) 天气代码到图标的映射
# --------------------------------------------------------------
# 参数: $1 - WMO 天气代码
# 输出: 对应的 Nerd Font 图标
icon_for_code () {
  case "$1" in
      # 代码 0: 晴天
      0)  w_icon="" ;;

      # 代码 1-3: 多云/阴天
      1|2|3) w_icon="" ;;

      # 代码 45-48: 雾
      45|48) w_icon="󰖑" ;;

      # 代码 51-57: 毛毛雨/雨
      51|53|55|56|57) w_icon="" ;;

      # 代码 61-67: 雨
      61|63|65|66|67) w_icon="" ;;

      # 代码 71-77: 雪
      71|73|75|77) w_icon="" ;;

      # 代码 80-82: 阵雨
      80|81|82) w_icon="" ;;

      # 代码 95-99: 雷暴
      95|96|99) w_icon="" ;;

      # 默认: 多云
      *)  w_icon="" ;;
  esac

  # 目前设计为纯文本显示，不使用图标
  # 如果需要图标，注释掉下面这行
  w_icon=""

  echo $w_icon
}

# --------------------------------------------------------------
# 4) 缓存 + UI 更新
# --------------------------------------------------------------
if [ -n "$RAW_TEMP" ]; then
  # ========== 成功获取数据 ==========
  # 格式化温度（整数）
  TEMP=$(printf "%.0f°C" "$RAW_TEMP")

  # 获取对应图标
  ICON="$(icon_for_code "$CODE")"

  # 成功状态：使用强调色图标 + 亮色标签
  ICON_COLOR="$ACCENT"
  LABEL_COLOR="$FG"

  # 保存到缓存
  echo "TEMP='$TEMP'" > "$CACHE_FILE"
  echo "ICON='$ICON'" >> "$CACHE_FILE"
else
  # ========== 获取数据失败 ==========
  # 尝试使用缓存数据（变暗显示）
  if [ -f "$CACHE_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CACHE_FILE"
    ICON_COLOR="$MUTED"
    LABEL_COLOR="$MUTED"
  else
    # 缓存也不存在，显示离线状态
    TEMP="Offline"
    ICON=""
    ICON_COLOR="$MUTED"
    LABEL_COLOR="$MUTED"
  fi
fi

# --------------------------------------------------------------
# 5) 更新 SketchyBar 条目
# --------------------------------------------------------------
$SB_CMD --set "$NAME" \
  icon="$ICON" \
  icon.color=$ICON_COLOR \
  label="$TEMP" \
  label.color=$LABEL_COLOR
