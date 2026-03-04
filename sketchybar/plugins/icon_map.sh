#!/bin/bash
# ==============================================================
# 应用图标映射表 (Geek Glass)
# ==============================================================
# @author    Hao Feng (F1)
# @file      icon_map.sh
# @desc      将应用名称映射到 Nerd Font 图标
#
# 用法说明：
#   1. 首先加载此脚本：
#      source "$HOME/.config/sketchybar/plugins/icon_map.sh"
#
#   2. 然后调用映射函数：
#      __icon_map "Google Chrome"
#
#   3. 结果保存在 $icon_result 变量中：
#      echo "$icon_result"  # 输出: 
#
# 支持的应用：
#   浏览器: Chrome, Safari, Arc
#   开发: VSCode, Emacs
#   终端: Terminal, iTerm2, Warp
#   办公: Word, Excel, PowerPoint
#   其他: WeChat, Mail, Zotero 等
#
# 隐藏应用：
#   返回空字符串的应用将不会被显示
#
# @version   1.0.0 (2025-02-05)
#            - 初始版本，支持常用应用图标映射
#            - 添加 Finder 隐藏功能
# ==============================================================

# --------------------------------------------------------------
# 应用图标映射函数
# --------------------------------------------------------------
# 参数: $1 - 应用名称
# 输出: 将结果保存到全局变量 $icon_result 中
function __icon_map() {
    case "$1" in
        # ========== 浏览器 ==========
        "Arc" | "Google Chrome") icon_result="" ;;      # Chrome 图标

        # ========== 阅读/书籍 ==========
        "calibre" | "Calibre") icon_result="" ;;         # 电子书管理

        # ========== 开发工具 ==========
        "Code" | "VSCode") icon_result="" ;;             # VS Code
        "Emacs") icon_result="" ;;                       # Emacs 编辑器
        "Fork") icon_result="" ;;                       # Git 客户端

        # ========== 邮件/新闻 ==========
        "Mail" | "Mailspring") icon_result="" ;;        # 邮件客户端
        "NetNewsWire") icon_result="" ;;                # RSS 阅读器

        # ========== 浏览器 ==========
        "Safari" | "Safari Technology Preview") icon_result="" ;;  # Safari

        # ========== 终端 ==========
        "Terminal" | "iTerm2" | "Warp") icon_result="" ;;  # 终端模拟器

        # ========== 聊天/社交 ==========
        "WeChat") icon_result="" ;;                     # 微信

        # ========== 阅读 ==========
        "Weread" | "WeChat Read" | "微信读书") icon_result="" ;;  # 微信读书

        # ========== 数学/科学 ==========
        "Wolfram" | "Wolfram Mathematica" | "Wolfram Desktop") icon_result="" ;;  # Mathematica

        # ========== Microsoft Office ==========
        "Microsoft Word") icon_result="" ;;             # Word
        "Microsoft Excel") icon_result="" ;;            # Excel
        "Microsoft PowerPoint") icon_result="" ;;       # PowerPoint

        # ========== 学术工具 ==========
        "Zotero") icon_result="Ⓩ" ;;                    # 文献管理

        # ========== 隐藏应用 ==========
        # 返回空字符串的应用将不会被显示
        "Finder") icon_result="" ;;                     # Finder（不显示）

        # 其他隐藏窗口也可以加在这里
        "LoginWindow") icon_result="" ;;                # 登录窗口

        # ========== 默认图标 ==========
        # *) icon_result="" ;;  # 通用图标
        *) icon_result="" ;;
    esac
}
