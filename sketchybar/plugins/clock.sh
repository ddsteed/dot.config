#!/bin/bash
# HH:MM clock
if command -v sketchybar >/dev/null 2>&1; then
  SB="$(command -v sketchybar)"
elif [[ -x /opt/homebrew/bin/sketchybar ]]; then
  SB="/opt/homebrew/bin/sketchybar"
elif [[ -x /usr/local/bin/sketchybar ]]; then
  SB="/usr/local/bin/sketchybar"
else
  exit 0
fi
# Force English month abbrev like "Mar"
export LC_TIME=en_US_POSIX

time_str="$(date '+%H:%M')"
date_str="$(date '+%b %d')"

# This script is used by the clock item; update both time and date items.
"$SB" --set clock label="$time_str" \
      --set date  label="$date_str"
