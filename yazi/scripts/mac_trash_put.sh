#!/usr/bin/env bash
# =============================================================================
# macOS 回收站：删除脚本
# =============================================================================
# 作者: Hao Feng (F1)
# =============================================================================
# 版本历史:
#   v1.0.0 - 2025-02-20 - 初始版本
#   v1.1.0 - 2025-03-01 - 添加文件名冲突处理
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# 配置
# -----------------------------------------------------------------------------
TRASH_DIR="$HOME/.Trash"               # macOS 系统回收站目录
LOG_DIR="$HOME/.config/yazi/state"     # 日志存储目录
LOG_FILE="$LOG_DIR/mac_trash.log"      # 删除记录日志文件

# 创建必要的目录
mkdir -p "$TRASH_DIR" "$LOG_DIR"

# -----------------------------------------------------------------------------
# 函数定义
# -----------------------------------------------------------------------------

# 获取绝对路径
# 参数: 相对或绝对路径
# 返回: 绝对路径
abspath() {
    python3 - "$1" <<'PY'
import os, sys
print(os.path.abspath(sys.argv[1]))
PY
}

# 生成回收站内唯一文件名
# 避免同名文件覆盖
# 参数: 基础文件名
# 返回: 唯一文件名（如 "file.txt" 或 "file (1).txt"）
unique_name_in_trash() {
    local base="$1"
    local name="$base"
    local i=1
    while [[ -e "$TRASH_DIR/$name" ]]; do
        name="${base} (${i})"
        i=$((i+1))
    done
    printf '%s' "$name"
}

# 获取当前 UTC 时间戳 (ISO 8601 格式)
# 返回: 如 "2025-03-19T10:30:45.123456+00:00"
ts_now() {
    python3 - <<'PY'
from datetime import datetime, timezone
print(datetime.now(timezone.utc).isoformat())
PY
}

# -----------------------------------------------------------------------------
# 主逻辑
# -----------------------------------------------------------------------------

# 检查参数
if [[ "$#" -lt 1 ]]; then
    echo "用法: $0 <文件> [文件...]" >&2
    echo "No targets." >&2
    exit 1
fi

# 获取当前时间戳（所有文件共用）
ts="$(ts_now)"

# 处理每个文件
for p in "$@"; do
    # 获取源文件绝对路径
    src="$(abspath "$p")"

    # 跳过不存在的文件
    [[ -e "$src" ]] || continue

    # 获取文件名
    base="$(basename "$src")"

    # 生成回收站内唯一文件名（处理同名冲突）
    dst_name="$(unique_name_in_trash "$base")"
    dst="$TRASH_DIR/$dst_name"

    # 移动文件到回收站
    # 注意: macOS 的 mv (BSD) 不支持 -- 选项
    mv "$src" "$dst"

    # 记录删除日志（JSON 格式）
    # 格式: {"ts": "时间戳", "src": "原路径", "dst": "回收站路径"}
    python3 - "$ts" "$src" "$dst" "$LOG_FILE" <<'PY'
import json, sys
ts, src, dst, logf = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
with open(logf, "a", encoding="utf-8") as f:
    f.write(json.dumps({"ts": ts, "src": src, "dst": dst}, ensure_ascii=False) + "\n")
PY
done
