#!/usr/bin/env bash
# =============================================================================
# macOS 回收站：恢复最近删除项脚本
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
LOG_FILE="$HOME/.config/yazi/state/mac_trash.log"

# -----------------------------------------------------------------------------
# 主逻辑
# -----------------------------------------------------------------------------

# 检查日志文件是否存在
if [[ ! -f "$LOG_FILE" ]]; then
    echo "回收站日志文件不存在: $LOG_FILE" >&2
    echo "请先使用删除脚本删除文件" >&2
    exit 1
fi

# 获取最后一行（最近删除的记录）
line="$(tail -n 1 "$LOG_FILE" || true)"
if [[ -z "$line" ]]; then
    echo "回收站日志为空" >&2
    exit 1
fi

# 使用 Python 执行恢复操作
python3 - "$line" <<'PY'
import json, os, sys, shutil

# 解析日志记录
rec = json.loads(sys.argv[1])
src = rec["src"]  # 原始路径
dst = rec["dst"]  # 回收站路径

# 检查回收站中的文件是否仍存在
if not os.path.exists(dst):
    print(f"回收站中未找到文件: {dst}", file=sys.stderr)
    sys.exit(2)

# 创建目标目录（如果不存在）
target_dir = os.path.dirname(src)
os.makedirs(target_dir, exist_ok=True)

# 构建最终目标路径
base = os.path.basename(src)
target = src

# 处理文件名冲突：如果原位置已有同名文件，添加后缀
if os.path.exists(target):
    i = 1
    while True:
        cand = os.path.join(target_dir, f"{base} (restored {i})")
        if not os.path.exists(cand):
            target = cand
            break
        i += 1

# 执行移动恢复
shutil.move(dst, target)

# 输出恢复后的路径（供 yazi 选中）
print(target)
PY
