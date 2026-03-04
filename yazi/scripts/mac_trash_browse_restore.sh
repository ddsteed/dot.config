#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="${HOME}/.config/yazi/state/mac_trash.log"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "No trash log found: $LOG_FILE" >&2
    exit 1
fi

# Require fzf for interactive picking
if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf not found. Install it: brew install fzf" >&2
    exit 2
fi

# Pick one record (most recent first)
# Show: time | original_path | trashed_name
pick="$(
  python3 - <<'PY' "$LOG_FILE" | fzf --prompt="Restore from ~/.Trash > " --height=80% --reverse
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

for ts,src,dst in rows[::-1]:
    trashed=os.path.basename(dst)
    print(f"{ts}\t{src}\t{trashed}\t{dst}")
PY
)"

[[ -z "${pick}" ]] && exit 0

# Parse selected line
ts="$(printf '%s' "$pick" | cut -f1)"
src="$(printf '%s' "$pick" | cut -f2)"
dst="$(printf '%s' "$pick" | cut -f4)"

python3 - <<'PY' "$ts" "$src" "$dst"
import os, sys, shutil
ts, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]

if not os.path.exists(dst):
    print(f"Not found in Trash: {dst}", file=sys.stderr)
    sys.exit(3)

target_dir = os.path.dirname(src)
os.makedirs(target_dir, exist_ok=True)

base = os.path.basename(src)
target = src

# If name collision, add suffix
if os.path.exists(target):
    i = 1
    while True:
        cand = os.path.join(target_dir, f"{base} (restored {i})")
        if not os.path.exists(cand):
            target = cand
            break
        i += 1

shutil.move(dst, target)
print(f"Restored:\n  From: {dst}\n  To:   {target}")
PY
