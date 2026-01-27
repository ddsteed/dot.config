#!/bin/bash

function __icon_map() {
    case "$1" in
        "Arc" | "Google Chrome") icon_result="" ;;
        "calibre" | "Calibre") icon_result="" ;;
        "Code" | "VSCode") icon_result="" ;;
        "Emacs") icon_result="" ;;
        "Fork") icon_result="" ;;
        "Safari" | "Safari Technology Preview") icon_result="" ;;
        "Terminal" | "iTerm2" | "Warp") icon_result="" ;;
        "WeChat") icon_result="" ;;
        "Weread" | "WeChat Read" | "微信读书") icon_result="" ;;
        "Wolfram" | "Wolfram Mathematica" | "Wolfram Desktop") icon_result="" ;;
        "Microsoft Word") icon_result="" ;;
        "Microsoft Excel") icon_result="" ;;
        "Microsoft PowerPoint") icon_result="" ;;
        "Zotero") icon_result="Ⓩ" ;;

        # 隐藏 Finder (返回空)
        "Finder") icon_result="" ;;

        # 如果有些隐藏窗口也不想显示，也可以加在这里
        "LoginWindow") icon_result="" ;;

        #*) icon_result="" ;;
        *) icon_result="" ;;
    esac
}

