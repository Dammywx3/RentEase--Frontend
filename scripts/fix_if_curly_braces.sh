#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_if_braces_$TS"
mkdir -p "$BACKUP_DIR"

backup_file () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "🗂️ Backing up dart files..."
while IFS= read -r -d '' f; do
  backup_file "$f"
done < <(find lib -type f -name '*.dart' -print0)

echo "🛠️ Adding braces for one-line if statements (basic safe patterns)..."

python3 - <<'PY'
import re
from pathlib import Path

files = list(Path("lib").rglob("*.dart"))

# This targets patterns like:
# if (cond) statement;
# and converts to:
# if (cond) { statement; }
#
# It skips cases already with {, and skips multiline statements by being conservative.
pat = re.compile(r'(^[ \t]*if\s*\([^\)]*\)\s*)(?!\{)([A-Za-z_][^;\n]*;)\s*$', re.M)

changed = 0
for p in files:
    s = p.read_text(encoding="utf-8")
    new = pat.sub(r'\1{ \2 }', s)
    if new != s:
        p.write_text(new, encoding="utf-8")
        changed += 1

print(f"✅ Updated files: {changed}")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null

echo "🔎 flutter analyze..."
flutter analyze || true

echo "✅ Done. Backups: $BACKUP_DIR"
