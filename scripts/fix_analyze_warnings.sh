#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_$TS"
mkdir -p "$BACKUP_DIR"

backup_file () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

# ----------------------------
# 1) Replace withOpacity(...) -> withValues(alpha: ((255 * ...).round()))
# ----------------------------
echo "🛠️  Replacing withOpacity(...) across lib/ ..."
# backup all dart files first (safe but a bit heavy)
while IFS= read -r -d '' f; do
  backup_file "$f"
done < <(find lib -type f -name '*.dart' -print0)

# replace only when ".withOpacity(" appears
perl -0777 -i -pe '
  s/\.withOpacity\(\s*([^)]+?)\s*\)/.withValues(alpha: ((255 * ($1)).round()))/g
' $(find lib -type f -name '*.dart')

# ----------------------------
# 2) Fix "unnecessary_underscores" in separatorBuilder: (_, __) -> (_, i)
# ----------------------------
echo "🛠️  Fixing separatorBuilder (_, __) -> (_, i) ..."
perl -0777 -i -pe '
  s/separatorBuilder:\s*\(\s*_,\s*__\s*\)\s*=>/separatorBuilder: (_, i) =>/g
' $(find lib -type f -name '*.dart')

# ----------------------------
# 3) Remove specific unused imports shown by flutter analyze
# ----------------------------
echo "🧹 Removing known unused imports (targeted)..."

# listing_detail_screen.dart: unused go_router + routes.dart
if [ -f lib/features/agent/listings/listing_detail_screen.dart ]; then
  backup_file lib/features/agent/listings/listing_detail_screen.dart
  perl -i -ne '
    next if $_ =~ /^\s*import\s+["'\'']package:go_router\/go_router\.dart["'\''];\s*$/;
    next if $_ =~ /^\s*import\s+["'\'']package:rentease_frontend\/app\/router\/routes\.dart["'\''];\s*$/;
    print;
  ' lib/features/agent/listings/listing_detail_screen.dart
fi

# listings_screen.dart: unused toast_service.dart import
if [ -f lib/features/agent/listings/listings_screen.dart ]; then
  backup_file lib/features/agent/listings/listings_screen.dart
  perl -i -ne '
    next if $_ =~ /^\s*import\s+["'\'']\.\.\/\.\.\/\.\.\/shared\/services\/toast_service\.dart["'\''];\s*$/;
    print;
  ' lib/features/agent/listings/listings_screen.dart
fi

# ----------------------------
# 4) Dedupe imports at top of each dart file (safe)
# ----------------------------
echo "🧽 De-duping import lines at top of files..."

python3 - <<'PY'
import os, re
from pathlib import Path

def dedupe_imports(path: Path):
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines(True)

    # Find top import block: starts at first import/part, ends at first non-import/part/export line
    i = 0
    while i < len(lines) and lines[i].strip() == "":
        i += 1
    start = i

    def is_directive(line: str) -> bool:
        s = line.strip()
        return s.startswith("import ") or s.startswith("export ") or s.startswith("part ")

    while i < len(lines) and is_directive(lines[i]):
        i += 1
    end = i

    if start == end:
        return False

    block = lines[start:end]
    seen = set()
    out = []
    changed = False
    for ln in block:
        key = ln.strip()
        if key in seen:
            changed = True
            continue
        seen.add(key)
        out.append(ln)

    if not changed:
        return False

    new_text = "".join(lines[:start] + out + lines[end:])
    path.write_text(new_text, encoding="utf-8")
    return True

root = Path("lib")
changed_files = 0
for p in root.rglob("*.dart"):
    try:
        if dedupe_imports(p):
            changed_files += 1
    except Exception:
        pass

print(f"✅ Import de-dupe updated: {changed_files} file(s)")
PY

# ----------------------------
# 5) Format + analyze
# ----------------------------
echo "🎨 dart format (lib + test)..."
dart format lib test >/dev/null

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
