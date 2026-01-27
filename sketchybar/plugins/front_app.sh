#!/bin/bash

# $INFO 变量是 SketchyBar 在 front_app_switched 事件中自动传入的 APP 名字
if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set $NAME label="$INFO"
fi

