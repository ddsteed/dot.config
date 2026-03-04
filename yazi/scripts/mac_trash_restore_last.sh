#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="$HOME/.config/yazi/state/mac_trash.log"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "No trash log found: $LOG_FILE" >&2
    exit 1
fi

line="$(tail -n 1 "$LOG_FILE" || true)"
if [[ -z "$line" ]]; then
    echo "Trash log is empty." >&2
    exit 1
fi

python3 - "$line" <<'PY'
import json, os, sys, shutil

rec = json.loads(sys.argv[1])
src = rec["src"]
dst = rec["dst"]

if not os.path.exists(dst):
    print(f"Not found in Trash: {dst}", file=sys.stderr)
    sys.exit(2)

target_dir = os.path.dirname(src)
os.makedirs(target_dir, exist_ok=True)

base = os.path.basename(src)
target = src

if os.path.exists(target):
    i = 1
    while True:
        cand = os.path.join(target_dir, f"{base} (restored {i})")
        if not os.path.exists(cand):
            target = cand
            break
        i += 1

shutil.move(dst, target)
print(target)
PY
