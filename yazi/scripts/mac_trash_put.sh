#!/usr/bin/env bash
set -euo pipefail

TRASH_DIR="$HOME/.Trash"
LOG_DIR="$HOME/.config/yazi/state"
LOG_FILE="$LOG_DIR/mac_trash.log"

mkdir -p "$TRASH_DIR" "$LOG_DIR"

abspath() {
    python3 - "$1" <<'PY'
import os, sys
print(os.path.abspath(sys.argv[1]))
PY
}

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

ts_now() {
    python3 - <<'PY'
from datetime import datetime, timezone
print(datetime.now(timezone.utc).isoformat())
PY
}

if [[ "$#" -lt 1 ]]; then
    echo "No targets." >&2
    exit 1
fi

ts="$(ts_now)"

for p in "$@"; do
    src="$(abspath "$p")"
    [[ -e "$src" ]] || continue

    base="$(basename "$src")"
    dst_name="$(unique_name_in_trash "$base")"
    dst="$TRASH_DIR/$dst_name"

    # macOS mv (BSD) – no `--`
    mv "$src" "$dst"

    python3 - "$ts" "$src" "$dst" "$LOG_FILE" <<'PY'
import json, sys
ts, src, dst, logf = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
with open(logf, "a", encoding="utf-8") as f:
    f.write(json.dumps({"ts": ts, "src": src, "dst": dst}, ensure_ascii=False) + "\n")
PY
done

