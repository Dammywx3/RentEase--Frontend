#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_remaining_analyze_$TS"
mkdir -p "$BACKUP_DIR"

backup() {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

FILES=(
  "lib/features/agent/listings/create_listing/create_listing_stepper.dart"
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

# 1) Fix remaining curly braces lint:
# If a line is: if (cond) statement;
# -> if (cond) { statement; }
#
# Conservative: only single-line statements ending with ';' and no '{'
if_one_liner = re.compile(
    r'^([ \t]*if\s*\([^\)]*\)\s*)(?!\{)([^;\n]+;)\s*$',
    re.M
)

def fix_if_braces(p: Path) -> bool:
    if not p.exists():
        return False
    s0 = read(p)
    s1 = if_one_liner.sub(r'\1{ \2 }', s0)
    if s1 != s0:
        write(p, s1)
        return True
    return False

fix_if_braces(Path("lib/features/agent/listings/create_listing/create_listing_stepper.dart"))
fix_if_braces(Path("lib/features/agent/tenancies/tenancy_detail_screen.dart"))

# 2) Fix register_state.dart override issues:
# - Remove any @override that is NOT directly for "get user"
# - Ensure @override exists directly above "get user"
p = Path("lib/features/auth/ui/register/register_state.dart")
if p.exists():
    s0 = read(p)
    lines = s0.splitlines(True)

    # Remove @override lines that are not immediately followed by a line containing "get user"
    new_lines = []
    i = 0
    while i < len(lines):
        if lines[i].strip() == "@override":
            j = i + 1
            # skip empty lines
            while j < len(lines) and lines[j].strip() == "":
                j += 1
            if j < len(lines) and re.search(r'\bget\s+user\b', lines[j]):
                new_lines.append(lines[i])  # keep
            # else: drop this @override
            i += 1
            continue
        new_lines.append(lines[i])
        i += 1

    s1 = "".join(new_lines)

    # Ensure @override directly above the first "get user" that lacks it
    lines = s1.splitlines(True)
    out = []
    i = 0
    inserted = False
    while i < len(lines):
        if (not inserted) and re.search(r'^\s*.*\bget\s+user\b', lines[i]):
            # find previous non-empty line in out
            k = len(out) - 1
            while k >= 0 and out[k].strip() == "":
                k -= 1
            prev = out[k].strip() if k >= 0 else ""
            if prev != "@override":
                indent = re.match(r'^(\s*)', lines[i]).group(1)
                out.append(f"{indent}@override\n")
            inserted = True
        out.append(lines[i])
        i += 1

    s2 = "".join(out)
    if s2 != s0:
        write(p, s2)

# 3) Revert initialValue -> value ONLY in the two files that error out.
def revert_initial_value(p: Path) -> None:
    if not p.exists():
        return
    s0 = read(p)
    # Only replace the parameter label (start of line or after whitespace)
    s1 = re.sub(r'(^[ \t]*)initialValue\s*:', r'\1value:', s0, flags=re.M)
    if s1 != s0:
        write(p, s1)

revert_initial_value(Path("lib/features/tenant/maintenance/create_request_screen.dart"))
revert_initial_value(Path("lib/features/tenant/profile/documents/upload_document_screen.dart"))

print("✅ Script edits applied.")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
