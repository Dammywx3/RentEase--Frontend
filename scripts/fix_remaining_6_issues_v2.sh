#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_remaining_6_v2_$TS"
mkdir -p "$BACKUP_DIR"

backup () {
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
  "lib/shared/widgets/form_field.dart"
)

echo "🗂️ Backing up likely touched files (only if they exist)..."
for f in "${FILES[@]}"; do
  backup "$f" || true
done

echo "🛠️ Applying robust fixes (py3.8/3.9 compatible)..."
python3 - <<'PY'
from pathlib import Path
import re

def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def write(p: Path, s: str) -> None:
    p.write_text(s, encoding="utf-8")

# --------------------------------------------
# A) Fix remaining "if (...) statement" without braces
#    Handles multi-line statements too (ends at semicolon + balanced parentheses).
# --------------------------------------------
ten = Path("lib/features/agent/tenancies/tenancy_detail_screen.dart")
if ten.exists():
    s0 = read(ten)
    lines = s0.splitlines(True)

    def is_if_header(line: str):
        return re.match(r'^(\s*)if\s*\((.*)\)\s*(//.*)?\s*$', line)

    def has_block(line: str) -> bool:
        return bool(re.search(r'\)\s*\{', line))

    def is_else_like(line: str) -> bool:
        t = line.lstrip()
        return t.startswith("else") or t.startswith("if ")

    def net_balance(chunk: str):
        par = chunk.count("(") - chunk.count(")")
        brk = chunk.count("[") - chunk.count("]")
        return par, brk

    changed = False
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]

        # same-line if with statement (no braces): if (x) doThing();
        m_same = re.match(r'^(\s*)if\s*\((.*)\)\s*(?!\{)([^;\n]+;)\s*(//.*)?\s*$', line)
        if m_same and not has_block(line):
            indent, cond, stmt, comment = m_same.group(1), m_same.group(2), m_same.group(3).strip(), m_same.group(4) or ""
            out.append(f"{indent}if ({cond}) {{ {stmt} }}{comment}\n")
            changed = True
            i += 1
            continue

        m = is_if_header(line)
        if not m or has_block(line):
            out.append(line)
            i += 1
            continue

        indent, cond = m.group(1), m.group(2)
        comment = m.group(3) or ""

        # find next non-empty line (body start)
        j = i + 1
        while j < len(lines) and lines[j].strip() == "":
            j += 1
        if j >= len(lines):
            out.append(line)
            i += 1
            continue

        nxt = lines[j]
        if nxt.lstrip().startswith("{") or is_else_like(nxt):
            out.append(line)
            i += 1
            continue

        # collect a single statement body that ends with ';' (may span multiple lines)
        body_lines = []
        k = j
        par_bal = 0
        brk_bal = 0
        while k < len(lines):
            body_lines.append(lines[k])
            par_delta, brk_delta = net_balance(lines[k])
            par_bal += par_delta
            brk_bal += brk_delta

            if re.search(r';\s*(//.*)?\s*$', lines[k]) and par_bal <= 0 and brk_bal <= 0:
                break
            k += 1

        if k >= len(lines):
            out.append(line)
            i += 1
            continue

        # rewrite with braces
        out.append(f"{indent}if ({cond}) {{{comment}\n")
        out.extend(body_lines)
        out.append(f"{indent}}}\n")
        changed = True

        i = k + 1

    s1 = "".join(out)
    if changed and s1 != s0:
        write(ten, s1)

# --------------------------------------------
# B) Fix register_state.dart override issues
#    - remove ALL @override lines
#    - add @override ONLY above the first "user" getter/member
# --------------------------------------------
rs = Path("lib/features/auth/ui/register/register_state.dart")
if rs.exists():
    s0 = read(rs)
    s1 = re.sub(r'^\s*@override\s*$\n?', '', s0, flags=re.M)

    lines = s1.splitlines(True)
    out = []
    inserted = False

    patt = re.compile(
        r'^\s*(?:final|late)?\s*.*\bget\s+user\b'
        r'|^\s*(?:final|late)?\s*.*\buser\s*[,;=]',
        re.I
    )

    for ln in lines:
        if (not inserted) and patt.search(ln):
            indent = re.match(r'^(\s*)', ln).group(1)
            out.append(f"{indent}@override\n")
            inserted = True
        out.append(ln)

    s2 = "".join(out)
    if s2 != s0:
        write(rs, s2)

# --------------------------------------------
# C) OPTIONAL: Fix "value deprecated" infos by supporting initialValue
#    in your custom AppFormField (if present), then switch screens.
# --------------------------------------------
form_field = Path("lib/shared/widgets/form_field.dart")
if form_field.exists():
    s0 = read(form_field)

    if "class AppFormField" in s0 and "initialValue" not in s0:
        s = s0

        # Add initialValue param in constructor where "this.value" exists
        s = re.sub(
            r'(AppFormField\s*\(\s*\{[^}]*?)\bthis\.value\b',
            r'\1this.initialValue,\n    this.value',
            s,
            flags=re.S
        )

        # Add field declaration near value
        s = re.sub(
            r'(\n\s*final\s+[^;\n]*\s+value\s*;\s*\n)',
            r'\n  final String? initialValue;\1',
            s
        )

        # Prefer initialValue ?? value in TextFormField
        s = re.sub(
            r'initialValue\s*:\s*value\s*,',
            r'initialValue: initialValue ?? value,',
            s
        )

        # If controller.text is set from value, respect initialValue too
        s = re.sub(
            r'controller\.text\s*=\s*value\s*;',
            r'controller.text = (initialValue ?? value) ?? "";',
            s
        )

        if s != s0:
            write(form_field, s)

# Convert AppFormField(value: ...) -> AppFormField(initialValue: ...)
targets = [
    Path("lib/features/tenant/maintenance/create_request_screen.dart"),
    Path("lib/features/tenant/profile/documents/upload_document_screen.dart"),
]
for p in targets:
    if not p.exists():
        continue
    s0 = read(p)
    s1 = re.sub(r'(AppFormField\s*\(.*?)(\b)value\s*:', r'\1initialValue:', s0, flags=re.S)
    if s1 != s0:
        write(p, s1)

print("✅ Patch complete.")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
