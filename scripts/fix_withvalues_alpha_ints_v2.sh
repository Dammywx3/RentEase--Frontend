#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_withvalues_alpha_ints_$TS"
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

echo "🛠️ Rewriting withValues(alpha: <int>) -> withValues(alpha: <double>) ..."

python3 - <<'PY'
import re
from pathlib import Path

pattern = re.compile(r'withValues\(\s*alpha:\s*([0-9]{1,3})\s*\)')

def repl(m: re.Match) -> str:
    n = int(m.group(1))
    # Only transform valid 0..255 ints
    if n < 0 or n > 255:
        return m.group(0)
    a = n / 255.0
    # Keep it readable and stable
    return f"withValues(alpha: {a:.6f})"

changed = 0
files = list(Path("lib").rglob("*.dart"))

for p in files:
    s = p.read_text(encoding="utf-8")
    s2, n = pattern.subn(repl, s)
    if n:
        p.write_text(s2, encoding="utf-8")
        changed += n

print(f"✅ Updated {changed} occurrence(s) across {len(files)} file(s).")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
