#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_warnings_infos_$TS"
mkdir -p "$BACKUP_DIR"

backup () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

FILES=(
  "lib/features/auth/ui/register/register_state.dart"
  "lib/features/tenant/maintenance/create_request_screen.dart"
  "lib/features/tenant/profile/documents/upload_document_screen.dart"
)

echo "🗂️ Backing up files..."
for f in "${FILES[@]}"; do
  backup "$f" || true
done

echo "🛠️ Patching..."
python3 - <<'PY'
from pathlib import Path
import re

def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def write(p: Path, s: str) -> None:
    p.write_text(s, encoding="utf-8")

# ---------------------------------------------------------
# 1) Fix register_state.dart:
#    - If there are multiple "user" members, treat the FIRST as the one
#      incorrectly annotated, and ensure it has NO @override directly above.
#    - Ensure ALL other "user" members DO have @override directly above.
# ---------------------------------------------------------
p = Path("lib/features/auth/ui/register/register_state.dart")
if p.exists():
    s0 = read(p)
    lines = s0.splitlines(True)

    # Identify "user" member lines (getter or field)
    user_pat = re.compile(r'^\s*(?:@override\s*)?\s*(?:.*\s+)?(?:get\s+user\b|\buser\b\s*[,;=])', re.I)
    user_idxs = [i for i, ln in enumerate(lines) if user_pat.search(ln)]

    # Helper: remove @override line immediately above index i (skipping blank lines)
    def remove_override_above(i: int):
        j = i - 1
        while j >= 0 and lines[j].strip() == "":
            j -= 1
        if j >= 0 and re.match(r'^\s*@override\s*$', lines[j]):
            lines[j] = ""  # delete it

    # Helper: ensure @override line immediately above index i (inserting above)
    def ensure_override_above(i: int):
        j = i - 1
        while j >= 0 and lines[j].strip() == "":
            j -= 1
        if j >= 0 and re.match(r'^\s*@override\s*$', lines[j]):
            return
        indent = re.match(r'^(\s*)', lines[i]).group(1)
        lines.insert(i, f"{indent}@override\n")

    if len(user_idxs) >= 2:
        # Remove @override above the first occurrence (likely the non-overriding one)
        remove_override_above(user_idxs[0])

        # Recompute indices after possible deletion (no line count change), but after inserts we must be careful:
        # We'll re-scan after cleaning the first, then ensure override on later ones.
        temp = "".join(lines)
        lines = temp.splitlines(True)
        user_idxs = [i for i, ln in enumerate(lines) if user_pat.search(ln)]

        # Ensure @override on all occurrences after the first
        # Insertions will shift indices; loop with while
        k = 1
        while k < len(user_idxs):
            idx = user_idxs[k]
            ensure_override_above(idx)
            # re-scan after insertion
            temp = "".join(lines)
            lines = temp.splitlines(True)
            user_idxs = [i for i, ln in enumerate(lines) if user_pat.search(ln)]
            k += 1
    else:
        # If only one "user" found: safest is remove any @override above it (avoid warning)
        if user_idxs:
            remove_override_above(user_idxs[0])

    s1 = "".join(lines)

    # Also: if there is ANY stray @override stacked multiple times, compress it (optional safety)
    s1 = re.sub(r'^\s*@override\s*$\n(\s*@override\s*$\n)+', '@override\n', s1, flags=re.M)

    if s1 != s0:
        write(p, s1)

# ---------------------------------------------------------
# 2) Replace AppFormField(value: ...) -> AppFormField(initialValue: ...)
#    Only inside AppFormField(...) calls, conservative.
# ---------------------------------------------------------
targets = [
    Path("lib/features/tenant/maintenance/create_request_screen.dart"),
    Path("lib/features/tenant/profile/documents/upload_document_screen.dart"),
]

# Replace "value:" to "initialValue:" ONLY if it occurs after "AppFormField(" before the next ");"
block_pat = re.compile(r'(AppFormField\s*\()(.*?)(\)\s*[,;])', re.S)

def fix_block(m: re.Match) -> str:
    head, body, tail = m.group(1), m.group(2), m.group(3)
    # swap named param "value:" -> "initialValue:" (only when it's a named arg)
    body2 = re.sub(r'(\b)value\s*:', r'\1initialValue:', body)
    return head + body2 + tail

for t in targets:
    if not t.exists():
        continue
    s0 = read(t)
    s1 = block_pat.sub(fix_block, s0)
    if s1 != s0:
        write(t, s1)

print("✅ Patch complete.")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "��️ Backups saved in: $BACKUP_DIR"
