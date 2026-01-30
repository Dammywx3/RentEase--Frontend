#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_all_$TS"
mkdir -p "$BACKUP_DIR"

backup_file () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "🗂️ Backing up all dart files..."
while IFS= read -r -d '' f; do
  backup_file "$f"
done < <(find lib -type f -name '*.dart' -print0)

echo "🛠️ Applying fixes..."

python3 - <<'PY'
import re
from pathlib import Path

dart_files = list(Path("lib").rglob("*.dart"))

def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def write(p: Path, s: str) -> None:
    p.write_text(s, encoding="utf-8")

total_changes = 0

# 1) Undo wrong replacements inside DropdownButtonFormField and DropdownMenuItem:
#    - DropdownButtonFormField(initialValue: ...) -> DropdownButtonFormField(value: ...)
#    - DropdownMenuItem(initialValue: ...) -> DropdownMenuItem(value: ...)
def fix_dropdown_blocks(s: str) -> tuple[str, int]:
    changes = 0

    # Fix DropdownButtonFormField initialValue -> value
    s2, n1 = re.subn(r'\bDropdownButtonFormField<([^>]+)>\s*\(', r'DropdownButtonFormField<\1>(', s)
    # (n1 not a "change" but keep consistent)

    s3, n2 = re.subn(r'(\bDropdownButtonFormField(?:<[^>]+>)?\s*\(\s*)(initialValue\s*:)', r'\1value:', s2)
    changes += n2

    # Fix DropdownMenuItem initialValue -> value (works for both inline and multiline)
    s4, n3 = re.subn(r'(\bDropdownMenuItem(?:<[^>]+>)?\s*\(\s*)(initialValue\s*:)', r'\1value:', s3)
    changes += n3

    return s4, changes

# 2) Add braces to one-line if statements (conservative)
#    if (cond) statement;  -> if (cond) { statement; }
if_one_liner = re.compile(r'(^[ \t]*if\s*\([^\)]*\)\s*)(?!\{)([A-Za-z_][^;\n]*;)\s*$', re.M)

def fix_if_braces(s: str) -> tuple[str, int]:
    s2, n = if_one_liner.subn(r'\1{ \2 }', s)
    return s2, n

# 3) Fix register_state.dart override issues (two cases):
#   A) Remove incorrect @override above a getter that doesn't actually override
#   B) Ensure @override exists on "user" when it's truly overriding
def fix_register_state(p: Path, s: str) -> tuple[str, int]:
    if "lib/features/auth/ui/register/register_state.dart" not in str(p):
        return s, 0

    changes = 0

    # Remove @override directly preceding a getter called "user" ONLY if analyzer complains "doesn't override".
    # We can't perfectly know, so we do a safe rule:
    # If there is a getter named "user" and it is not marked @override, we add it.
    # If there is "@override" right before a getter named "userRole"/something else and that getter isn't in parent, we won't touch.
    #
    # Step 1: Ensure @override above "user" getter/field if it exists
    # Matches:
    #   <newline>  UserModel get user => ...
    # or:
    #   UserModel? get user => ...
    pat_user_getter = re.compile(r'(?m)^(?!\s*@override\s*\n)(\s*)([A-Za-z0-9_<>\?\s]+)\s+get\s+user\s*=>')
    s2, n1 = pat_user_getter.subn(r'\1@override\n\1\2 get user =>', s)
    changes += n1

    # Step 2: Remove @override above anything that is NOT a method/getter/setter override for safety? Too risky.
    # Instead we ONLY remove @override if it's immediately above "get user" AND analyzer still says it doesn't override.
    # Since we can’t read analyzer output here, we won’t remove it blindly.
    # (You can manually remove later if warning persists.)

    return s2, changes

for p in dart_files:
    s0 = read(p)
    s = s0

    s, n = fix_dropdown_blocks(s)
    total_changes += n

    s, n = fix_if_braces(s)
    total_changes += n

    s, n = fix_register_state(p, s)
    total_changes += n

    if s != s0:
        write(p, s)

print(f"✅ Total replacements/edits: {total_changes}")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
