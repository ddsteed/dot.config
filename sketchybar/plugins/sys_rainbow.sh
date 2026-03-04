#!/bin/bash
# Update CPU/MEM rainbow sliders + percent labels (sketchybar v2.23.0 compatible)

# Find sketchybar binary reliably (LaunchAgent PATH can be minimal)
if command -v sketchybar >/dev/null 2>&1; then
  SB="$(command -v sketchybar)"
elif [[ -x /opt/homebrew/bin/sketchybar ]]; then
  SB="/opt/homebrew/bin/sketchybar"
elif [[ -x /usr/local/bin/sketchybar ]]; then
  SB="/usr/local/bin/sketchybar"
else
  exit 0
fi

clamp_0_100() {
  local v="$1"
  if [[ -z "$v" ]]; then echo 0; return; fi
  if (( v < 0 )); then echo 0
  elif (( v > 100 )); then echo 100
  else echo "$v"
  fi
}

# -------- CPU used% (prefer top; fallback to per-process ps) --------
export LC_ALL=C

cpu_pct_f=""
cpu_pct_i=""

if command -v top >/dev/null 2>&1; then
  # Use the 2nd sample (-l 2) for more stable numbers
  cpu_pct_f="$(top -l 2 -n 0 2>/dev/null | awk -F'[:,% ]+' '
    /CPU usage/ {u=$3; s=$5}
    END {
      if (u=="" || s=="") {exit 1}
      v=u+s
      if (v<0) v=0
      if (v>100) v=100
      printf "%.1f", v
    }' )"
fi

if [[ -z "$cpu_pct_f" ]]; then
  cores="$(sysctl -n hw.logicalcpu 2>/dev/null)"
  [[ -z "$cores" || "$cores" -le 0 ]] && cores=1

  # Sum per-process CPU% (can exceed 100 on multi-core), then normalize by core count
  cpu_sum="$(ps -A -o %cpu= 2>/dev/null | awk '{gsub(",",".",$1); s+=$1} END{printf "%.2f", s+0}')"
  [[ -z "$cpu_sum" ]] && cpu_sum=0
  cpu_pct_f="$(awk -v s="$cpu_sum" -v c="$cores" 'BEGIN{v=s/c; if(v<0)v=0; if(v>100)v=100; printf "%.0f", v}')"
fi

# Clamp + derive integer percentage for slider/color
cpu_pct_i="$(awk -v v="$cpu_pct_f" 'BEGIN{if(v==""){v=0}; if(v<0)v=0; if(v>100)v=100; printf "%.0f", v}')"
cpu_pct_i="$(clamp_0_100 "$cpu_pct_i")"
cpu_pct_f="$(awk -v v="$cpu_pct_f" 'BEGIN{if(v==""){v=0}; if(v<0)v=0; if(v>100)v=100; printf "%.0f", v}')"

# -------- MEM used% (prefer memory_pressure; fallback to vm_stat) --------
# -------- MEM used% (Activity Monitor-like: active + wired + compressed) --------
mem_pct=""

PAGE_SIZE="$(sysctl -n hw.pagesize 2>/dev/null)"
MEM_TOTAL="$(sysctl -n hw.memsize 2>/dev/null)"
vm="$(vm_stat 2>/dev/null)"

get_pages() {
    echo "$vm" | awk -F': +' -v k="$1" '$0 ~ k { gsub("\\.","",$2); print $2; exit }'
}

active="$(get_pages 'Pages active')"
wired="$(get_pages 'Pages wired down')"
compressed="$(get_pages 'Pages occupied by compressor')"
[[ -z "$compressed" ]] && compressed=0

if [[ -n "$active" && -n "$wired" && -n "$MEM_TOTAL" && -n "$PAGE_SIZE" ]]; then
    used_pages=$((active + wired + compressed))
    used_bytes=$((used_pages * PAGE_SIZE))
    mem_pct="$(awk -v u="$used_bytes" -v t="$MEM_TOTAL" 'BEGIN{v=(u*100)/t; if(v<0)v=0; if(v>100)v=100; printf "%.0f", v}')"
else
    mem_pct="0"
fi

mem_pct="$(clamp_0_100 "$mem_pct")"

# -------- rainbow color by level --------
rainbow_color() {
  local p="$1"
  if   (( p < 15 )); then echo "0xFF00B0FF"   # blue
  elif (( p < 30 )); then echo "0xFF00FF6A"   # green
  elif (( p < 45 )); then echo "0xFFFFFF00"   # yellow
  elif (( p < 60 )); then echo "0xFFFFA500"   # orange
  elif (( p < 75 )); then echo "0xFFFF4500"   # orange-red
  elif (( p < 90 )); then echo "0xFFFF0000"   # red
  else                  echo "0xFFB000FF"     # purple
  fi
}

cpu_color="$(rainbow_color "$cpu_pct_i")"
mem_color="$(rainbow_color "$mem_pct")"

"$SB" --set cpu.slider slider.percentage="$cpu_pct_i" slider.highlight_color="$cpu_color"
"$SB" --set mem.slider slider.percentage="$mem_pct" slider.highlight_color="$mem_color"
cpu_label="$(printf "%3d%%" "$cpu_pct_i")"
mem_label="$(printf "%3d%%" "$mem_pct")"

"$SB" --set cpu.pct label="$cpu_label" label.color="$cpu_color"
"$SB" --set mem.pct label="$mem_label" label.color="$mem_color"

