#!/bin/bash

# ==============================================================
# input.sh - 诊断版 (带详细日志)
# ==============================================================

# 定义日志文件
#LOG_FILE="/tmp/input_debug.log"
LOG_FILE="/dev/null"

# 记录脚本开始运行的时间和触发者
echo "--- $(date '+%H:%M:%S') 触发者: ${SENDER:-手动运行} ---" >> $LOG_FILE

# 1. 确定组件名称
# 如果 SketchyBar 没传名字进来，默认为 "input"
# 【关键】请确保你的 sketchybarrc 里定义的 item 名字也是 "input"
TARGET_NAME="${NAME:-input}"
echo "目标组件: [$TARGET_NAME]" >> $LOG_FILE

# 2. 获取输入法 ID (使用验证过的 JXA 代码)
CURRENT_SOURCE=$(osascript -l JavaScript -e "
function run() {
  ObjC.import('Carbon');
  var source = $.TISCopyCurrentKeyboardInputSource();
  var id = $.TISGetInputSourceProperty(source, $.kTISPropertyInputSourceID);
  var nsString = ObjC.castRefToObject(id);
  return nsString.js;
}" 2>/dev/null)

echo "获取到的 ID: [$CURRENT_SOURCE]" >> $LOG_FILE

# 3. 逻辑匹配
case "$CURRENT_SOURCE" in
    *"Squirrel"* | *"rime"*)
        #LABEL="Rime"
        LABEL="  "
        ICON="🐹"
        ICON=""
        ;;
    *"ABC"* | *"US"* | *"keylayout.ABC"*)
        #LABEL="ENG"
        LABEL="En "
        #ICON="🇺🇸"
        ICON=" "
        ;;
    *"sogou"*)
        LABEL="中"
        ICON="🇨🇳"
        ;;
    *)
        LABEL="??"
        ICON="❓"
        ;;
esac

echo "准备设置: 图标=[$ICON] 标签=[$LABEL]" >> $LOG_FILE

# 4. 执行更新并记录结果
# 捕获 sketchybar 的返回信息，看是否有报错 (比如 Item not found)
OUTPUT=$(sketchybar --set "$TARGET_NAME" icon="$ICON" label="$LABEL" 2>&1)

if [ $? -eq 0 ]; then
    echo "更新成功" >> $LOG_FILE
else
    echo "更新失败! 错误信息: $OUTPUT" >> $LOG_FILE
fi

echo "------------------------------------------------" >> $LOG_FILE

