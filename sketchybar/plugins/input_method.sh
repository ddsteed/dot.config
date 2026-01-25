#!/bin/bash
id="$(macism)"   # 输出当前输入源ID，例如 com.apple.keylayout.US
label="$id"

# 很粗但实用的映射：键盘布局一般是英文，inputmethod 一般是中文/日文等
if [[ "$id" == *"keylayout"* ]]; then
  label="EN"
elif [[ "$id" == *"inputmethod"* ]]; then
  label="中"
else
  # 兜底：只显示最后一段
  label="${id##*.}"
fi

sketchybar --set input_method label="$label"
