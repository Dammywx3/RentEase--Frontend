#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FILE="lib/features/tenant/alerts/alerts_screen.dart"

if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_alerts_lint_$TS"
mkdir -p "$BACKUP_DIR/$(dirname "$FILE")"
cp "$FILE" "$BACKUP_DIR/$FILE"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/tenant/alerts/alerts_screen.dart")
s = p.read_text(encoding="utf-8")

# Replace: separatorBuilder: (_, __) => ...
# With: separatorBuilder: (context, index) => ...
s2, n = re.subn(
    r"separatorBuilder:\s*\(\s*_,\s*__\s*\)\s*=>",
    "separatorBuilder: (context, index) =>",
    s
)

p.write_text(s2, encoding="utf-8")
print(f"✅ Updated separatorBuilder underscores -> named args ({n} change).")
PY

dart format "$FILE" >/dev/null || true
flutter analyze || true

echo "✅ Done. Backup: $BACKUP_DIR"
