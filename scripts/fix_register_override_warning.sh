#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FILE="lib/features/auth/ui/register/register_state.dart"

if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_register_override_$TS"
mkdir -p "$BACKUP_DIR/$(dirname "$FILE")"
cp "$FILE" "$BACKUP_DIR/$FILE"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/auth/ui/register/register_state.dart")
s = p.read_text(encoding="utf-8")

# Remove @override only if it is immediately above: "<type> get user"
pat = re.compile(r'(?m)^\s*@override\s*\n(\s*[A-Za-z0-9_<>\?\s]+\s+get\s+user\b)')
s2, n = pat.subn(r'\1', s)

p.write_text(s2, encoding="utf-8")
print(f"✅ Removed {n} invalid @override annotation(s) above `get user`.")
PY

dart format "$FILE" >/dev/null || true
flutter analyze || true

echo "✅ Done. Backup: $BACKUP_DIR"
