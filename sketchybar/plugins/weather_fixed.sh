#!/bin/bash
# ==========================================================
# SketchyBar Weather Plugin (Geek Glass)
# - Uses Open-Meteo current_weather
# - Uses ip-api for coarse IP geolocation (with fallback)
# - Uses theme colors if available
# ==========================================================

NAME="${NAME:-weather}"
CACHE_FILE="/tmp/weather_cache.sh"

# Find sketchybar binary
if [ -x "/opt/homebrew/bin/sketchybar" ]; then
  SB_CMD="/opt/homebrew/bin/sketchybar"
else
  SB_CMD="$(command -v sketchybar)"
fi

# Load theme if present
THEME_FILE="$HOME/.config/sketchybar/theme.sh"
if [[ -f "$THEME_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$THEME_FILE"
fi

# Fallback colors if theme missing
FG="${FG:-0xFFEDEDED}"
MUTED="${MUTED:-0xFF8A8F98}"
ACCENT="${ACCENT:-0xFF66D9EF}"

# ------------------------------
# 1) Location (try direct first)
# ------------------------------
LOC_DATA=$(curl -s --noproxy "*" --max-time 12 "http://ip-api.com/json/")
LAT=$(echo "$LOC_DATA" | grep -o '"lat":[0-9.-]*' | head -n 1 | cut -d: -f2)
LON=$(echo "$LOC_DATA" | grep -o '"lon":[0-9.-]*' | head -n 1 | cut -d: -f2)

# If direct failed, try normal curl (some networks require proxy)
if [[ ! "$LAT" =~ ^[0-9.-]+$ ]]; then
  LOC_DATA=$(curl -s --max-time 12 "http://ip-api.com/json/")
  LAT=$(echo "$LOC_DATA" | grep -o '"lat":[0-9.-]*' | head -n 1 | cut -d: -f2)
  LON=$(echo "$LOC_DATA" | grep -o '"lon":[0-9.-]*' | head -n 1 | cut -d: -f2)
fi

# Final fallback (Chengdu)
if [[ ! "$LAT" =~ ^[0-9.-]+$ ]]; then
  LAT="30.57"; LON="104.06"
fi

# ------------------------------
# 2) Fetch weather
# ------------------------------
URL="https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current_weather=true"
DATA=$(curl -s --max-time 12 "$URL")

RAW_TEMP=$(echo "$DATA" | grep -oE '"temperature":[0-9.-]+' | head -n 1 | cut -d: -f2)
CODE=$(echo "$DATA" | grep -oE '"weathercode":[0-9]+' | head -n 1 | cut -d: -f2)

# ------------------------------
# 3) Icon mapping (monochrome geek)
# ------------------------------
icon_for_code () {
  case "$1" in
      0)  w_icon="" ;;                 # clear
      1|2|3) w_icon="" ;;               # partly cloudy
      45|48) w_icon="󰖑" ;;              # fog
      51|53|55|56|57) w_icon="" ;;      # drizzle
      61|63|65|66|67) w_icon="" ;;      # rain
      71|73|75|77) w_icon="" ;;         # snow
      80|81|82) w_icon="" ;;            # showers
      95|96|99) w_icon="" ;;            # thunder
      *)  w_icon="" ;;
  esac
  w_icon=""
  echo $w_icon
}

# ------------------------------
# 4) Cache + UI update
# ------------------------------
if [ -n "$RAW_TEMP" ]; then
  TEMP=$(printf "%.0f°C" "$RAW_TEMP")
  ICON="$(icon_for_code "$CODE")"

  # Success: accent icon + bright label
  ICON_COLOR="$ACCENT"
  LABEL_COLOR="$FG"

  echo "TEMP='$TEMP'" > "$CACHE_FILE"
  echo "ICON='$ICON'" >> "$CACHE_FILE"
else
  # Fail: use cache (dimmed)
  if [ -f "$CACHE_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CACHE_FILE"
    ICON_COLOR="$MUTED"
    LABEL_COLOR="$MUTED"
  else
    TEMP="Offline"
    ICON=""
    ICON_COLOR="$MUTED"
    LABEL_COLOR="$MUTED"
  fi
fi

$SB_CMD --set "$NAME"   icon="$ICON"   icon.color=$ICON_COLOR   label="$TEMP"   label.color=$LABEL_COLOR
