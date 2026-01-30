#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_remaining_$TS"
mkdir -p "$BACKUP_DIR"

backup() {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

FILE_LISTING="lib/features/agent/listings/listing_detail_screen.dart"
FILE_MODEL="lib/shared/models/listing_model.dart"

echo "🗂️ Backing up files..."
backup "$FILE_LISTING"
backup "$FILE_MODEL"

echo "🛠️ Fixing duplicate imports in: $FILE_LISTING"
python3 - <<'PY'
from pathlib import Path

path = Path("lib/features/agent/listings/listing_detail_screen.dart")
if not path.exists():
    raise SystemExit(f"Missing file: {path}")

lines = path.read_text(encoding="utf-8").splitlines(True)

# Identify top import section
i = 0
while i < len(lines) and (lines[i].lstrip().startswith("import ") or lines[i].strip() == ""):
    i += 1

imports_block = lines[:i]
rest = lines[i:]

# Remove the specific package imports (these caused duplicates)
drop_exact = {
    "import 'package:rentease_frontend/features/agent/applications/applications_screen.dart';\n",
    "import 'package:rentease_frontend/features/agent/viewings/viewings_screen.dart';\n",
    "import \"package:rentease_frontend/features/agent/applications/applications_screen.dart\";\n",
    "import \"package:rentease_frontend/features/agent/viewings/viewings_screen.dart\";\n",
}

new_block = []
seen = set()

for ln in imports_block:
    if ln in drop_exact:
        continue
    # Deduplicate exact import lines only (leave blank lines alone)
    if ln.lstrip().startswith("import "):
        if ln in seen:
            continue
        seen.add(ln)
    new_block.append(ln)

path.write_text("".join(new_block + rest), encoding="utf-8")
print("✅ listing_detail_screen.dart: removed target package imports + deduped imports")
PY

echo "🛠️ Removing unused _dt() helper in: $FILE_MODEL"
python3 - <<'PY'
from pathlib import Path

path = Path("lib/shared/models/listing_model.dart")
if not path.exists():
    raise SystemExit(f"Missing file: {path}")

s = path.read_text(encoding="utf-8")

needle = "static DateTime? _dt"
idx = s.find(needle)
if idx == -1:
    print("ℹ️ _dt() not found; skipping")
    raise SystemExit(0)

# Find the opening brace for the method
brace_open = s.find("{", idx)
if brace_open == -1:
    print("⚠️ Found _dt signature but no '{' brace; skipping")
    raise SystemExit(0)

# Walk forward counting braces to find the method end
depth = 0
j = brace_open
while j < len(s):
    ch = s[j]
    if ch == "{":
        depth += 1
    elif ch == "}":
        depth -= 1
        if depth == 0:
            # include closing brace
            end = j + 1
            break
    j += 1
else:
    print("⚠️ Could not find end of _dt() block; skipping")
    raise SystemExit(0)

# Remove surrounding whitespace/newlines cleanly
before = s[:idx]
after = s[end:]

# If there are extra blank lines left behind, normalize lightly
out = (before.rstrip() + "\n\n" + after.lstrip())
path.write_text(out, encoding="utf-8")
print("✅ listing_model.dart: removed unused _dt() method")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
