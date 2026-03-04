#!/bin/bash
# ==============================================================
# Front app item (Geek Glass)
# - Shows icon + app name using icon_map.sh
# ==============================================================

source "$HOME/.config/sketchybar/plugins/icon_map.sh"

THEME_FILE="$HOME/.config/sketchybar/theme.sh"
if [[ -f "$THEME_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$THEME_FILE"
fi

FG="${FG:-0xFFEDEDED}"
MUTED="${MUTED:-0xFF8A8F98}"
ACCENT="${ACCENT:-0xFF66D9EF}"

if [[ "$SENDER" == "front_app_switched" ]]; then
  APP="$INFO"

  __icon_map "$APP"
  ICON="$icon_result"

  # Fallback icon if mapping is empty (but keep Finder hidden if you like)
  if [[ -z "$ICON" ]]; then
    ICON=""
  fi

  sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$ACCENT" \
    label="$APP" \
    label.color="$FG"
fi
