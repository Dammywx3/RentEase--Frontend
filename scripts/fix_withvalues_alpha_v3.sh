#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_withvalues_alpha_v3_$TS"
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

echo "🛠️ Fixing Color.withValues(alpha: ...) usages..."

python3 - <<'PY'
import re
from pathlib import Path

files = list(Path("lib").rglob("*.dart"))

# 1) alpha: ((255 * (0.25)).round())  -> alpha: 0.25
#    alpha: ((255 * (.45)).round())   -> alpha: .45
#    alpha: (255 * 0.35).round()      -> alpha: 0.35
round_patterns = [
    # alpha: ((255 * (0.25)).round())
    re.compile(r'alpha:\s*\(\(\s*255\s*\*\s*\(\s*([0-9]*\.?[0-9]+|\.[0-9]+)\s*\)\s*\)\s*\.round\(\)\s*\)'),
    # alpha: ((255 * 0.25).round())
    re.compile(r'alpha:\s*\(\(\s*255\s*\*\s*([0-9]*\.?[0-9]+|\.[0-9]+)\s*\)\s*\.round\(\)\s*\)'),
    # alpha: (255 * 0.25).round()
    re.compile(r'alpha:\s*\(\s*255\s*\*\s*([0-9]*\.?[0-9]+|\.[0-9]+)\s*\)\s*\.round\(\)'),
]

# 2) alpha: 64  (or alpha: 64, ...) -> alpha: 0.250980
int_pattern = re.compile(r'alpha:\s*([0-9]{1,3})(?=\s*[,)\]])')

def repl_round(m: re.Match) -> str:
    x = m.group(1).strip()
    return f"alpha: {x}"

def repl_int(m: re.Match) -> str:
    n = int(m.group(1))
    if n < 0 or n > 255:
        return m.group(0)
    a = n / 255.0
    return f"alpha: {a:.6f}"

total_changes = 0

for p in files:
    s = p.read_text(encoding="utf-8")
    original = s

    # Apply round-pattern simplifications
    for pat in round_patterns:
        s, n = pat.subn(repl_round, s)
        total_changes += n

    # Apply int -> double conversion
    s, n2 = int_pattern.subn(repl_int, s)
    total_changes += n2

    if s != original:
        p.write_text(s, encoding="utf-8")

print(f"✅ Total replacements: {total_changes}")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
