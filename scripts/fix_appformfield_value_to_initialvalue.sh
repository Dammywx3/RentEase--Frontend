#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_appformfield_value_$TS"
mkdir -p "$BACKUP_DIR"

backup () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

FILES=(
  "lib/features/tenant/maintenance/create_request_screen.dart"
  "lib/features/tenant/profile/documents/upload_document_screen.dart"
)

echo "🗂️ Backing up target files..."
for f in "${FILES[@]}"; do
  backup "$f"
done

echo "🛠️ Rewriting AppFormField(value:) -> AppFormField(initialValue:) safely..."
python3 - <<'PY'
from pathlib import Path
import re

targets = [
    Path("lib/features/tenant/maintenance/create_request_screen.dart"),
    Path("lib/features/tenant/profile/documents/upload_document_screen.dart"),
]

def find_matching_paren(s: str, open_idx: int) -> int:
    # open_idx points to '('
    depth = 0
    i = open_idx
    in_str = None  # "'" or '"'
    escape = False

    while i < len(s):
        ch = s[i]

        # handle strings
        if in_str:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == in_str:
                in_str = None
            i += 1
            continue
        else:
            if ch in ("'", '"'):
                in_str = ch
                i += 1
                continue

        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1

    return -1

total_changes = 0

for p in targets:
    if not p.exists():
        continue

    s = p.read_text(encoding="utf-8")
    out = []
    i = 0

    while True:
        idx = s.find("AppFormField(", i)
        if idx == -1:
            out.append(s[i:])
            break

        out.append(s[i:idx])
        start = idx
        open_paren = idx + len("AppFormField")
        # open_paren should be at '('
        if open_paren >= len(s) or s[open_paren] != "(":
            # weird edge case, just copy and continue
            out.append(s[idx:idx+12])
            i = idx + 12
            continue

        close_paren = find_matching_paren(s, open_paren)
        if close_paren == -1:
            # couldn't parse, just copy rest and stop
            out.append(s[idx:])
            break

        block = s[start:close_paren+1]

        # Replace ONLY named argument "value:" inside this AppFormField(...) block.
        # (won't touch text like "somevalue:" etc due to word boundary)
        new_block, n = re.subn(r"\bvalue\s*:", "initialValue:", block)
        total_changes += n

        out.append(new_block)
        i = close_paren + 1

    new_s = "".join(out)
    if new_s != s:
        p.write_text(new_s, encoding="utf-8")

print(f"✅ Replaced {total_changes} occurrence(s).")
PY

echo "🎨 dart format..."
dart format "${FILES[@]}" >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
