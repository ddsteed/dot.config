#!/bin/bash
# ==============================================================
# CPU/MEM 系统监控插件 (彩虹配色风格)
# ==============================================================
# @author    Hao Feng (F1)
# @file      sys_rainbow.sh
# @desc      显示 CPU 和内存使用率，使用彩虹渐变配色
#
# 功能说明：
#   - CPU: 显示当前 CPU 使用率百分比
#   - MEM: 显示内存使用率百分比（active + wired + compressed）
#   - 颜色: 根据负载动态变化（青→亮青→黄→橙→红→紫）
#
# 颜色分级：
#   < 15%: 青色 (空闲)
#   < 30%: 亮青色 (良好)
#   < 45%: 黄色 (中等)
#   < 60%: 橙色 (较高)
#   < 75%: 橙红 (高)
#   < 90%: 红色 (很高)
#   ≥ 90%: 紫色 (警告)
#
# 更新频率：5 秒
# 兼容版本：sketchybar v2.23.0+
#
# @version   1.0.1 (2026-03-19)
#            - 统一版本格式
#            1.0.0 (2025-03-04)
#            - 初始版本，添加 CPU/MEM 双滑块监控
#            - 实现彩虹颜色渐变逻辑
# ==============================================================

# --------------------------------------------------------------
# 查找 sketchybar 可执行文件
# --------------------------------------------------------------
# LaunchAgent 的 PATH 可能不完整，需要手动查找
if command -v sketchybar >/dev/null 2>&1; then
  SB="$(command -v sketchybar)"
elif [[ -x /opt/homebrew/bin/sketchybar ]]; then
  SB="/opt/homebrew/bin/sketchybar"
elif [[ -x /usr/local/bin/sketchybar ]]; then
  SB="/usr/local/bin/sketchybar"
else
  exit 0
fi

# --------------------------------------------------------------
# 辅助函数：将数值限制在 0-100 范围内
# --------------------------------------------------------------
# $1: 输入数值
# 输出: 限制在 0-100 之间的数值
clamp_0_100() {
  local v="$1"
  if [[ -z "$v" ]]; then echo 0; return; fi
  if (( v < 0 )); then echo 0
  elif (( v > 100 )); then echo 100
  else echo "$v"
  fi
}

# --------------------------------------------------------------
# CPU 使用率计算
# --------------------------------------------------------------
# 设置本地化环境（确保 top 输出为英文格式）
export LC_ALL=C

cpu_pct_f=""  # CPU 使用率（浮点数）
cpu_pct_i=""  # CPU 使用率（整数）

# 优先使用 top 命令（更准确）
if command -v top >/dev/null 2>&1; then
  # -l 2: 采样两次，第二次更准确
  # -n 0: 不限制进程数量
  # awk 解析输出：
  #   /CPU usage/: 匹配包含 "CPU usage" 的行
  #   u=$3: user 使用率
  #   s=$5: sys 使用率
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

# 如果 top 失败，使用 ps 命令回退方案
if [[ -z "$cpu_pct_f" ]]; then
  # 获取 CPU 核心数
  cores="$(sysctl -n hw.logicalcpu 2>/dev/null)"
  [[ -z "$cores" || "$cores" -le 0 ]] && cores=1

  # 计算所有进程的 CPU 使用率之和
  # ps -A -o %cpu=: 输出所有进程的 CPU 使用率
  # 可能在多核系统上超过 100%，需要归一化
  cpu_sum="$(ps -A -o %cpu= 2>/dev/null | awk '{gsub(",",".",$1); s+=$1} END{printf "%.2f", s+0}')"
  [[ -z "$cpu_sum" ]] && cpu_sum=0

  # 除以核心数得到实际使用率
  cpu_pct_f="$(awk -v s="$cpu_sum" -v c="$cores" 'BEGIN{v=s/c; if(v<0)v=0; if(v>100)v=100; printf "%.0f", v}')"
fi

# 限制在 0-100 并转换为整数
cpu_pct_i="$(awk -v v="$cpu_pct_f" 'BEGIN{if(v==""){v=0}; if(v<0)v=0; if(v>100)v=100; printf "%.0f", v}')"
cpu_pct_i="$(clamp_0_100 "$cpu_pct_i")"
cpu_pct_f="$(awk -v v="$cpu_pct_f" 'BEGIN{if(v==""){v=0}; if(v<0)v=0; if(v>100)v=100; printf "%.0f", v}')"

# --------------------------------------------------------------
# 内存使用率计算
# --------------------------------------------------------------
# 使用 vm_stat 获取内存统计信息
# 计算方式: active + wired + compressed (类似活动监视器)
PAGE_SIZE="$(sysctl -n hw.pagesize 2>/dev/null)"    # 页面大小
MEM_TOTAL="$(sysctl -n hw.memsize 2>/dev/null)"     # 总内存
vm="$(vm_stat 2>/dev/null)"                         # 虚拟内存统计

# 辅助函数：从 vm_stat 输出中提取指定页面的数量
get_pages() {
    echo "$vm" | awk -F': +' -v k="$1" '$0 ~ k { gsub("\\.","",$2); print $2; exit }'
}

# 获取各类页面数量
active="$(get_pages 'Pages active')"                  # 活跃页面
wired="$(get_pages 'Pages wired down')"              # 锁定页面
compressed="$(get_pages 'Pages occupied by compressor')"  # 压缩页面
[[ -z "$compressed" ]] && compressed=0

# 计算内存使用率
if [[ -n "$active" && -n "$wired" && -n "$MEM_TOTAL" && -n "$PAGE_SIZE" ]]; then
    used_pages=$((active + wired + compressed))
    used_bytes=$((used_pages * PAGE_SIZE))
    mem_pct="$(awk -v u="$used_bytes" -v t="$MEM_TOTAL" 'BEGIN{v=(u*100)/t; if(v<0)v=0; if(v>100)v=100; printf "%.0f", v}')"
else
    mem_pct="0"
fi

# 限制在 0-100
mem_pct="$(clamp_0_100 "$mem_pct")"

# --------------------------------------------------------------
# 彩虹颜色函数
# --------------------------------------------------------------
# $1: 百分比值 (0-100)
# 输出: ARGB 格式的颜色值
rainbow_color() {
  local p="$1"
  if   (( p < 15 )); then echo "0xFF66D9EF"   # 青色 - 空闲
  elif (( p < 30 )); then echo "0xFF5DC8E8"   # 橙色 - 良好
  elif (( p < 45 )); then echo "0xFFFFFF00"   # 黄色 - 中等
  elif (( p < 60 )); then echo "0xFFFFA500"   # 橙色 - 较高
  elif (( p < 75 )); then echo "0xFFFF4500"   # 橙红 - 高
  elif (( p < 90 )); then echo "0xFFFF0000"   # 红色 - 很高
  else                  echo "0xFFB000FF"     # 紫色 - 警告
  fi
}

# --------------------------------------------------------------
# 根据使用率获取颜色
# --------------------------------------------------------------
cpu_color="$(rainbow_color "$cpu_pct_i")"
mem_color="$(rainbow_color "$mem_pct")"

# --------------------------------------------------------------
# 更新滑块和标签
# --------------------------------------------------------------
# CPU 滑块
"$SB" --set cpu.slider slider.percentage="$cpu_pct_i" slider.highlight_color="$cpu_color"

# MEM 滑块
"$SB" --set mem.slider slider.percentage="$mem_pct" slider.highlight_color="$mem_color"

# CPU 百分比标签（右对齐，宽度 3 字符）
cpu_label="$(printf "%3d%%" "$cpu_pct_i")"

# MEM 百分比标签
mem_label="$(printf "%3d%%" "$mem_pct")"

# 更新标签文本和颜色
"$SB" --set cpu.pct label="$cpu_label" label.color="$cpu_color"
"$SB" --set mem.pct label="$mem_label" label.color="$mem_color"
