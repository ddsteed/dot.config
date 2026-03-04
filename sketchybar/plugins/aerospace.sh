#!/bin/bash
# ==============================================================
# Aerospace workspace item renderer (Geek Glass)
# Requirements implemented:
# 1) Highlight focused workspace
# 2) Hide workspaces with no (visible) apps
# 3) Workspaces >= 5 are supported by creating enough items in sketchybarrc
# ==============================================================

source "$HOME/.config/sketchybar/plugins/icon_map.sh"

THEME_FILE="$HOME/.config/sketchybar/theme.sh"
if [[ -f "$THEME_FILE" ]]; then
    source "$THEME_FILE"
fi

FG="${FG:-0xFFEDEDED}"
ACCENT="${ACCENT:-0xFF66D9EF}"
WORKSPACE_INACTIVE="${WORKSPACE_INACTIVE:-0xFFD0D0D0}"

SID="$1"

# Focused workspace(s)
# If AeroSpace triggers the event with FOCUSED_WORKSPACE, use that (faster).
# Otherwise query AeroSpace directly.
if [[ -n "${FOCUSED_WORKSPACE:-}" ]]; then
    FOCUSED_WORKSPACES="$(printf '%s\n' "$FOCUSED_WORKSPACE" | tr -d '\r')"
else
    FOCUSED_WORKSPACES="$(aerospace list-workspaces --focused 2>/dev/null | tr -d '\r')"
fi

# Apps in this workspace (unique)
APPS="$(aerospace list-windows --workspace "$SID" --format "%{app-name}" 2>/dev/null | sort -u)"

# Build icon label string + whether we have any *visible* apps
ICON_STR=""
HAS_VISIBLE_APPS=0
if [[ -n "$APPS" ]]; then
    while read -r app; do
        [[ -z "$app" ]] && continue
        __icon_map "$app"
        [[ -z "${icon_result:-}" ]] && continue   # treat Finder/LoginWindow as "invisible"
        HAS_VISIBLE_APPS=1

        if [[ -z "$ICON_STR" ]]; then
            ICON_STR="$icon_result"
        else
            ICON_STR="$ICON_STR  $icon_result"
        fi
    done <<< "$APPS"
fi

# Is focused?
if echo "$FOCUSED_WORKSPACES" | grep -qx "$SID"; then
    IS_FOCUSED=1
else
    IS_FOCUSED=0
fi

# Drawing rule:
# - Always show focused workspace (even if empty), so "current workspace" can be highlighted.
# - Otherwise, show only if it has visible apps.
if [[ "$IS_FOCUSED" -eq 1 || "$HAS_VISIBLE_APPS" -eq 1 ]]; then
    DRAWING="on"
else
    DRAWING="off"
fi

# Style
if [[ "$IS_FOCUSED" -eq 1 ]]; then
    ICON_COLOR="$ACCENT"
    LABEL_COLOR="$FG"
    BG_DRAWING="on"
    BG_COLOR="$ACCENT"
    BG_HEIGHT=3
    BG_RADIUS=2
    BG_Y_OFFSET=12
else
    ICON_COLOR="$WORKSPACE_INACTIVE"
    LABEL_COLOR="$WORKSPACE_INACTIVE"
    BG_DRAWING="off"
    BG_COLOR=0x00000000
    BG_HEIGHT=0
    BG_RADIUS=0
    BG_Y_OFFSET=0
fi

sketchybar --set "$NAME" \
           drawing="$DRAWING" \
           icon="$SID" \
           icon.color="$ICON_COLOR" \
           label="$ICON_STR" \
           label.color="$LABEL_COLOR" \
           background.drawing="$BG_DRAWING" \
           background.color="$BG_COLOR" \
           background.height="$BG_HEIGHT" \
           background.corner_radius="$BG_RADIUS" \
           background.y_offset="$BG_Y_OFFSET"

