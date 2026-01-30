#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_remaining_5_$TS"
mkdir -p "$BACKUP_DIR"

backup() {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

FILES=(
  "lib/features/agent/tenancies/tenancy_detail_screen.dart"
  "lib/features/auth/ui/register/register_state.dart"
  "lib/features/tenant/maintenance/create_request_screen.dart"
  "lib/features/tenant/profile/documents/upload_document_screen.dart"
)

echo "🗂️ Backing up touched files..."
for f in "${FILES[@]}"; do
  backup "$f"
done

echo "🛠️ Applying fixes..."
python3 - <<'PY'
from pathlib import Path
import re

def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def write(p: Path, s: str) -> None:
    p.write_text(s, encoding="utf-8")

# 1) Fix the remaining curly-braces info in tenancy_detail_screen.dart
ten = Path("lib/features/agent/tenancies/tenancy_detail_screen.dart")
if ten.exists():
    s0 = read(ten)
    lines = s0.splitlines(True)

    def wrap_same_line(line: str) -> str:
        # if (cond) stmt;  -> if (cond) { stmt; }
        m = re.match(r'^(\s*)if\s*\((.*)\)\s*(?!\{)([^;\n]+;)(\s*//.*)?\s*$', line)
        if not m:
            return line
        indent, cond, stmt, comment = m.group(1), m.group(2), m.group(3).strip(), m.group(4) or ""
        # avoid weird cases
        if stmt.startswith("else") or stmt.startswith("if "):
            return line
        return f"{indent}if ({cond}) {{ {stmt} }}{comment}\n"

    changed = False

    # pass A: same-line if (cond) stmt;
    new_lines = []
    for line in lines:
        nl = wrap_same_line(line)
        if nl != line:
            changed = True
        new_lines.append(nl)
    lines = new_lines

    # pass B: multiline:
    # if (cond)
    #   stmt;
    i = 0
    while i < len(lines):
        line = lines[i]
        m = re.match(r'^(\s*)if\s*\((.*)\)\s*$', line)
        if not m:
            i += 1
            continue
        indent, cond = m.group(1), m.group(2)

        # find next non-empty line
        j = i + 1
        while j < len(lines) and lines[j].strip() == "":
            j += 1
        if j >= len(lines):
            break

        nxt = lines[j]
        # skip if next line begins a block or is else/if
        if nxt.lstrip().startswith("{") or nxt.lstrip().startswith("else") or nxt.lstrip().startswith("if "):
            i += 1
            continue

        # only wrap a single statement that ends with ';'
        if not re.search(r';\s*(//.*)?\s*$', nxt):
            i += 1
            continue

        # Rewrite
        lines[i] = f"{indent}if ({cond}) {{\n"
        stmt_body = nxt.lstrip()
        lines[j] = f"{indent}  {stmt_body}"
        lines.insert(j + 1, f"{indent}}}\n")
        changed = True
        i = j + 2

    if changed:
        write(ten, "".join(lines))

# 2) Fix register_state.dart:
#    - remove ALL @override lines (they're causing the warning)
#    - then add @override ONLY before the 'user' member (getter or field)
rs = Path("lib/features/auth/ui/register/register_state.dart")
if rs.exists():
    s0 = read(rs)
    lines = s0.splitlines(True)

    # remove all @override
    lines2 = [ln for ln in lines if ln.strip() != "@override"]
    s1 = "".join(lines2)

    # add @override above first "user" member
    patt_user = re.compile(
        r'^(\s*)(?:late\s+|final\s+)?[A-Za-z_]\w*(?:<[^;>]*>)?(?:\?)?\s+user\b|^(\s*).*?\bget\s+user\b',
        re.M
    )

    out = []
    inserted = False
    for ln in s1.splitlines(True):
        if not inserted and patt_user.search(ln):
            indent = re.match(r'^(\s*)', ln).group(1)
            out.append(f"{indent}@override\n")
            inserted = True
        out.append(ln)

    s2 = "".join(out)
    if s2 != s0:
        write(rs, s2)

# 3) Fix the 2 build errors: your custom field does NOT support initialValue,
#    so revert initialValue: back to value: in those two files.
targets = [
    Path("lib/features/tenant/maintenance/create_request_screen.dart"),
    Path("lib/features/tenant/profile/documents/upload_document_screen.dart"),
]
for p in targets:
    if not p.exists():
        continue
    s0 = read(p)
    s1 = re.sub(r'(^\s*)initialValue\s*:', r'\1value:', s0, flags=re.M)
    if s1 != s0:
        write(p, s1)

print("✅ Fixes applied.")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
