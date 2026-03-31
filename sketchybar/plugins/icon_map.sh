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
# 隐藏应用：
#   返回空字符串的应用将不会被显示
#
# 图标风格：
#   - 简洁：选择最简单的图标字符
#   - 美观：使用统一的 Nerd Font 风格
#   - 颜色：自动使用天蓝色 (0xFF7EDEFF) 与 fox logo 匹配
#
# @version   2.0.0 (2026-03-19)
#            - 全面更新所有应用图标
#            - 按功能类别组织
#            - 使用简洁美观的 Nerd Font 图标
#            - 清理重复代码块
# ==============================================================

# --------------------------------------------------------------
# 应用图标映射函数
# --------------------------------------------------------------
# 参数: $1 - 应用名称
# 输出: 将结果保存到全局变量 $icon_result 中
function __icon_map() {
    case "$1" in

        # ========== 浏览器 ==========
        "Arc") icon_result="󰊯" ;;                           # Arc 独特图标（紫色弧形）
        "Google Chrome") icon_result="" ;;                  # Chrome 图标
        "Safari" | "Safari Technology Preview") icon_result="" ;;  # Safari
        "Microsoft Edge") icon_result="" ;;                 # Edge

        # ========== 开发工具 ==========
        "Code" | "VSCode" | "Visual Studio Code") icon_result="" ;;  # VS Code
        "Cursor") icon_result="λ" ;;                         # Cursor AI
        "Emacs") icon_result="" ;;                          # Emacs 编辑器
        "Eclipse") icon_result="" ;;                        # Eclipse IDE
        "Vimlike") icon_result="" ;;                        # Vim-like
        "OpenCode") icon_result="⌥" ;;                       # OpenCode
        "Wolfram" | "Wolfram Mathematica" | "Wolfram Desktop" | "Wolfram Engine" | "WolframScript" | "Wolfram.app") icon_result="∫" ;;  # Mathematica/计算
        "Ollama") icon_result="󰙚" ;;                        # Ollama AI
        "Cherry Studio") icon_result="" ;;                  # AI 工具
        "DeepChat") icon_result="💬" ;;                     # DeepChat AI
        "Doubao") icon_result="🤖" ;;                       # 豆包 AI
        "Auto-Claude") icon_result="" ;;                    # Claude

        # ========== 终端与命令行 ==========
        "Terminal" | "iTerm2" | "Warp" | "iTerm" | "Ghostty") icon_result="" ;;  # 终端
        "Hammerspoon") icon_result="⌨︎" ;;                    # Hammerspoon 自动化
        "Karabiner-Elements" | "Karabiner-EventViewer") icon_result="⌨︎" ;;  # Karabiner 键盘

        # ========== Git 与版本控制 ==========
        "Fork") icon_result="" ;;                            # Git 客户端
        "GitX") icon_result="" ;;                            # GitX

        # ========== 数据库 ==========
        "Another Redis Desktop Manager") icon_result="" ;;   # Redis
        "Neo4j Desktop 2") icon_result="" ;;                 # Neo4j 图数据库

        # ========== 容器与虚拟化 ==========
        "Docker") icon_result="" ;;                          # Docker
        "OrbStack") icon_result="⊞" ;;                        # OrbStack Docker

        # ========== 笔记与知识管理 ==========
        "Obsidian") icon_result="" ;;                        # Obsidian 笔记
        "Logseq") icon_result="" ;;                          # Logseq 笔记
        "Notion") icon_result="" ;;                          # Notion（如果安装）
        "Notes") icon_result="" ;;                           # macOS 备忘录（便签图标）

        # ========== 阅读与文档 ==========
        "calibre" | "Calibre") icon_result="📚" ;;            # 电子书管理
        "Kindle") icon_result="" ;;                          # Kindle 阅读器
        "Weread" | "WeChat Read" | "微信读书") icon_result="📖" ;;   # 微信读书
        "Mendeley Reference Manager") icon_result="" ;;      # Mendeley 文献管理
        "Zotero") icon_result="Ⓩ" ;;                         # Zotero 文献管理

        # ========== 邮件与通讯 ==========
        "Mail" | "Mailspring" | "Microsoft Outlook") icon_result="✉️" ;;     # 邮件客户端
        "WeChat") icon_result="💬" ;;                         # 微信
        "Feishu") icon_result="📨" ;;                         # 飞书
        "企业微信" | "com.tencent.WorkMac") icon_result="🏢" ;; # 企业微信

        # ========== 新闻与 RSS ==========
        "NetNewsWire") icon_result="📰" ;;                    # RSS 阅读器

        # ========== 办公软件 ==========
        "Microsoft Word") icon_result="📄" ;;                 # Word
        "Microsoft Excel") icon_result="📊" ;;                # Excel
        "Microsoft PowerPoint") icon_result="📽" ;;            # PowerPoint
        "Microsoft OneNote") icon_result="📒" ;;              # OneNote
        "Pages") icon_result="📝" ;;                          # Pages
        "Numbers") icon_result="🔢" ;;                        # Numbers
        "Keynote") icon_result="📽" ;;                        # Keynote

        # ========== 图形与设计 ==========
        "GIMP") icon_result="🎨" ;;                           # GIMP 图像编辑
        "draw.io") icon_result="📈" ;;                        # Draw.io 流程图

        # ========== 视频与音频 ==========
        "IINA") icon_result="🎬" ;;                           # IINA 播放器
        "VLC" | "VLC media player") icon_result="🎞" ;;       # VLC
        "HandBrake") icon_result="⏯" ;;                       # HandBrake 转码
        "GarageBand") icon_result="🎵" ;;                     # GarageBand 音乐
        "iMovie") icon_result="🎥" ;;                         # iMovie 视频
        "LyricsX") icon_result="🎤" ;;                        # LyricsX 歌词
        "Kap") icon_result="⏺" ;;                              # Kap 录屏

        # ========== 云存储与网盘 ==========
        "Google Drive") icon_result="☁️" ;;                   # Google Drive
        "BaiduNetdisk_mac" | "百度网盘") icon_result="☁️" ;;  # 百度网盘
        "aDrive") icon_result="☁️" ;;                         # 阿里云盘
        "ctfile") icon_result="☁️" ;;                         # 城通网盘

        # ========== 系统工具 ==========
        "AppCleaner") icon_result="🧹" ;;                     # AppCleaner 卸载
        "OnyX") icon_result="🔧" ;;                           # OnyX 系统维护
        "Hidden Bar") icon_result="➖" ;;                     # Hidden Bar 隐藏菜单栏
        "Rectangle") icon_result="◻" ;;                       # Rectangle 窗口管理
        "Homerow") icon_result="⌨" ;;                         # Homerow 键盘学习
        "NameChanger") icon_result="✏" ;;                     # NameChanger 批量重命名
        "BetterDisplay") icon_result="🖥" ;;                  # BetterDisplay 显示
        "BetterCapture") icon_result="📸" ;;                 # BetterCapture 截图
        "Shottr") icon_result="📷" ;;                        # Shottr 截图
        "battery.app") icon_result="🔋" ;;                   # Battery
        "MacDown") icon_result="📝" ;;                       # MacDown Markdown
        "MacZip") icon_result="📦" ;;                        # MacZip 解压
        "OpenClaw") icon_result="🔧" ;;                      # OpenClaw
        "Nimble Commander") icon_result="📁" ;;              # 文件管理器

        # ========== AI 与开发工具 ==========
        "Trae" | "Trae CN") icon_result="🤖" ;;              # Trae AI
        "Langflow") icon_result="⚡" ;;                       # Langflow AI
        "WLJS Notebook") icon_result="📓" ;;                 # Jupyter Notebook

        # ========== 浏览器扩展与工具 ==========
        "wechatwebdevtools") icon_result="🛠" ;;             # 微信开发者工具
        "Shadowrocket") icon_result="🚀" ;;                  # Shadowrocket 代理
        "Clash Verge") icon_result="🛡" ;;                   # Clash 代理

        # ========== 娱乐与媒体 ==========
        "哔哩哔哩") icon_result="📺" ;;                       # Bilibili
        "YoutubeDownloader") icon_result="▶" ;;               # YouTube 下载
        "Deck") icon_result="🎮" ;;                           # Deck 游戏平台
        "Wine Stable") icon_result="🍷" ;;                    # Wine

        # ========== 镜像与投屏 ==========
        "Mirror for Samsung TV") icon_result="📺" ;;          # 三星电视镜像
        "OkaMirrorForSmartTV") icon_result="📺" ;;            # OKA 镜像

        # ========== 效率工具 ==========
        "Alfred 5") icon_result="🔍" ;;                       # Alfred 启动器
        "Raycast") icon_result="⌘" ;;                          # Raycast 启动器
        "Quark") icon_result="📦" ;;                          # 夸克网盘
        "Thunder") icon_result="⚡" ;;                         # 迅雷下载
        "Easydict") icon_result="📖" ;;                      # Easydict 翻译
        "PromptOptimizer") icon_result="✨" ;;               # Prompt 优化
        "Easydict") icon_result="📖" ;;                      # Easydict 翻译
        "PromptOptimizer") icon_result="✨" ;;               # Prompt 优化

        # ========== PDF 工具 ==========
        "PDF Marker" | "PDF"*) icon_result="📕" ;;           # PDF 标注/阅读
        "Preview") icon_result="📖" ;;                      # PDF 预览

        # ========== 窗口管理 ==========
        "AeroSpace") icon_result="⊞" ;;                      # AeroSpace 窗口管理器

        # ========== 其他工具 ==========
        "TeX") icon_result="𝑻" ;;                             # TeX 排版
        "Utilities") icon_result="🛠" ;;                     # 实用工具
        "PDF"*) icon_result="📕" ;;                          # PDF 相关

        # ========== 隐藏应用 ==========
        # 返回空字符串的应用将不会被显示
        "Finder") icon_result="" ;;                          # Finder（不显示）
        "LoginWindow") icon_result="" ;;                     # 登录窗口
        "Spotlight") icon_result="" ;;                       # Spotlight 搜索
        "Notification Center") icon_result="" ;;            # 通知中心

        # ========== 默认图标 ==========
        *) icon_result="" ;;                                # 通用图标
    esac
}
