#!/bin/bash
# ============================================================
# 鼠须管输入法焦点修复脚本
# ============================================================
# @author    Hao Feng (F1)
# @version   1.1.0
# @updated   2026-03-04
#
# 版本历史：
#   v1.1.0 (2026-03-04) - 添加详细中文注释和版本信息
#   v1.0.0 (2025-03-04) - 初始版本，修复焦点丢失问题
#
# 功能说明：
#   此脚本用于修复鼠须管（Squirrel）输入法候选词窗口导致的
#   输入焦点丢失问题。
#
# 问题背景：
#   在 AeroSpace 平铺窗口管理器中，当鼠须管的候选词窗口
#   出现时，可能会导致当前输入窗口失去焦点，需要手动点击
#   才能继续输入。
#
# 解决方案：
#   通过 AeroSpace 的 focus-back-and-forth 命令快速切换焦点，
#   让系统重新获取正确的输入焦点。
#
# 使用方式：
#   此脚本由 aerospace.toml 配置文件自动调用，
#   当检测到鼠须管窗口时自动执行。
# ============================================================

# 短暂延迟，确保窗口状态稳定
# 30ms 延迟让 AeroSpace 完成窗口状态更新
sleep 0.03

# 获取当前聚焦窗口的应用 Bundle ID
# aerospace list-windows：列出所有窗口
# --focused：仅返回当前聚焦的窗口
# --format '%{app-bundle-id}'：输出格式为应用 Bundle ID
# 2>/dev/null：屏蔽错误输出
FOCUS_APP=$(aerospace list-windows --focused --format '%{app-bundle-id}' 2>/dev/null)

# 检查当前聚焦的应用是否为鼠须管
# 鼠须管的 Bundle ID：im.rime.inputmethod.Squirrel
if [ "$FOCUS_APP" = "im.rime.inputmethod.Squirrel" ]; then
    # 执行焦点往返切换
    # focus-back-and-forth：切换到上一个聚焦的窗口，然后再切换回来
    # 这会强制系统重新获取正确的输入焦点
    aerospace focus-back-and-forth
fi

# ============================================================
# 脚本结束
# ============================================================
