#!/usr/bin/env bash
# =============================================================================
# macOS 回收站：交互式浏览恢复脚本
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
LOG_FILE="${HOME}/.config/yazi/state/mac_trash.log"

# -----------------------------------------------------------------------------
# 主逻辑
# -----------------------------------------------------------------------------

# 检查日志文件是否存在
if [[ ! -f "$LOG_FILE" ]]; then
    echo "回收站日志文件不存在: $LOG_FILE" >&2
    echo "请先使用删除脚本删除文件" >&2
    exit 1
fi

# 检查 fzf 是否安装
if ! command -v fzf >/dev/null 2>&1; then
    echo "错误: 未找到 fzf 命令" >&2
    echo "请安装: brew install fzf" >&2
    exit 2
fi

# ────────────────────────────────────────────────────────────────────────────
# 使用 fzf 交互式选择要恢复的文件
# ────────────────────────────────────────────────────────────────────────────
# 显示格式: 时间 | 原路径 | 回收站中的文件名
# 选择后解析选中的行并执行恢复
pick="$(
  python3 - <<'PY' "$LOG_FILE" | fzf --prompt="恢复文件 > " --height=80% --reverse
import json,sys,os
logf = sys.argv[1]
rows=[]
with open(logf,"r",encoding="utf-8") as f:
    for line in f:
        line=line.strip()
        if not line:
            continue
        try:
            rec=json.loads(line)
            ts=rec.get("ts","")
            src=rec.get("src","")
            dst=rec.get("dst","")
            rows.append((ts,src,dst))
        except Exception:
            pass

# 反转数组，使最新的记录显示在最前面
for ts,src,dst in rows[::-1]:
    trashed=os.path.basename(dst)
    # 格式: 时间\t原路径\t回收站文件名\t完整回收站路径
    print(f"{ts}\t{src}\t{trashed}\t{dst}")
PY
)"

# 用户取消选择则退出
[[ -z "${pick}" ]] && exit 0

# 解析选中的行
ts="$(printf '%s' "$pick" | cut -f1)"     # 时间戳
src="$(printf '%s' "$pick" | cut -f2)"    # 原路径
dst="$(printf '%s' "$pick" | cut -f4)"    # 回收站路径

# ────────────────────────────────────────────────────────────────────────────
# 执行恢复
# ────────────────────────────────────────────────────────────────────────────
python3 - "$ts" "$src" "$dst" <<'PY'
import os, sys, shutil
ts, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]

# 检查回收站中的文件是否仍存在
if not os.path.exists(dst):
    print(f"回收站中未找到文件: {dst}", file=sys.stderr)
    sys.exit(3)

# 创建目标目录
target_dir = os.path.dirname(src)
os.makedirs(target_dir, exist_ok=True)

# 构建目标路径
base = os.path.basename(src)
target = src

# 处理文件名冲突
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
print(f"已恢复:\n  从: {dst}\n  到: {target}")
PY
