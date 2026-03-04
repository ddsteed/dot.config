#!/bin/bash

INFO="$(pmset -g batt 2>/dev/null)"
PERCENT="$(echo "$INFO" | grep -Eo '[0-9]+%' | head -n1 | tr -d '%')"

if echo "$INFO" | grep -q "AC Power"; then
    STATE="↑"
    STATE_COLOR="0xFF00FF6A"   # green
else
    STATE="↓"
    STATE_COLOR="0xFFFF3B30"   # red
fi

if [[ -z "$PERCENT" ]]; then
    PERCENT="--"
fi

# Choose a color based on percentage (ARGB)
# You can change these to whatever you like.
if [[ "$PERCENT" == "--" ]]; then
    BAR_COLOR="0xFFFFFFFF"
else
    if (( PERCENT <= 20 )); then
        BAR_COLOR="0xFFFF3B30"   # red
    elif (( PERCENT <= 50 )); then
        BAR_COLOR="0xFFFFCC00"   # yellow
    else
        BAR_COLOR="0xFF00FF6A"   # green
    fi
fi

sketchybar \
    --set battery.state label="$STATE" label.color="$STATE_COLOR" \
    --set battery.pct   label="${PERCENT}%" label.color="$BAR_COLOR" \
    --set battery.slider slider.percentage="$PERCENT" slider.highlight_color="$BAR_COLOR"

