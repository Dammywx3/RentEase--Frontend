#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_dropdown_breakage_$TS"
mkdir -p "$BACKUP_DIR"

FILES=(
  "lib/features/tenant/maintenance/create_request_screen.dart"
  "lib/features/tenant/profile/documents/upload_document_screen.dart"
)

backup () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "🗂️ Backing up target files..."
for f in "${FILES[@]}"; do
  backup "$f"
done

echo "🛠️ Reverting initialValue -> value where appropriate, and adding ignore comments for DropdownButtonFormField..."

python3 - <<'PY'
from pathlib import Path
import re

files = [
    Path("lib/features/tenant/maintenance/create_request_screen.dart"),
    Path("lib/features/tenant/profile/documents/upload_document_screen.dart"),
]

def find_matching_paren(s: str, open_idx: int) -> int:
    depth = 0
    i = open_idx
    in_str = None
    esc = False
    while i < len(s):
        ch = s[i]
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
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

def fix_file(p: Path) -> int:
    s = p.read_text(encoding="utf-8")

    # 1) Revert DropdownMenuItem(initialValue: ...) -> DropdownMenuItem(value: ...)
    s = re.sub(r"(DropdownMenuItem\s*\([^)]*?)\binitialValue\s*:", r"\1value:", s, flags=re.S)

    # 2) Revert DropdownButtonFormField(initialValue: ...) -> DropdownButtonFormField(value: ...)
    # Do this safely per-widget-call (match parens)
    out = []
    i = 0
    changes = 0

    while True:
        idx = s.find("DropdownButtonFormField", i)
        if idx == -1:
            out.append(s[i:])
            break

        out.append(s[i:idx])

        open_paren = s.find("(", idx)
        if open_paren == -1:
            out.append(s[idx:])
            break

        close_paren = find_matching_paren(s, open_paren)
        if close_paren == -1:
            out.append(s[idx:])
            break

        block = s[idx:close_paren + 1]

        # Replace initialValue: -> value: inside this DropdownButtonFormField(...) call
        new_block, n1 = re.subn(r"\binitialValue\s*:", "value:", block)
        changes += n1

        # Add ignore comment directly above the value: line (if not already there)
        # Find the line containing "value:"
        lines = new_block.splitlines(True)
        for j in range(len(lines)):
            if re.search(r"^\s*value\s*:", lines[j]):
                # look back to find previous non-empty line
                k = j - 1
                while k >= 0 and lines[k].strip() == "":
                    k -= 1
                if k >= 0 and "ignore: deprecated_member_use" in lines[k]:
                    break  # already has ignore
                indent = re.match(r"^(\s*)", lines[j]).group(1)
                lines.insert(j, f"{indent}// ignore: deprecated_member_use\n")
                changes += 1
                break

        new_block2 = "".join(lines)
        out.append(new_block2)
        i = close_paren + 1

    new_s = "".join(out)
    if new_s != s:
        p.write_text(new_s, encoding="utf-8")

    return changes

total = 0
for p in files:
    if p.exists():
        total += fix_file(p)

print(f"✅ Total edits applied: {total}")
PY

echo "🎨 dart format..."
dart format "${FILES[@]}" >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
