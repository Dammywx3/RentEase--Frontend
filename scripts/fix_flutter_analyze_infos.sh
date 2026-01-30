#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_analyze_infos_$TS"
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
  "lib/features/agent/listings/create_listing/steps/basics_step.dart"
  "lib/features/agent/listings/create_listing/steps/pricing_step.dart"
  "lib/features/agent/tenancies/tenancy_detail_screen.dart"
  "lib/features/auth/ui/register/register_state.dart"
  "lib/features/tenant/maintenance/create_request_screen.dart"
  "lib/features/tenant/profile/documents/upload_document_screen.dart"
)

echo "🗂️ Backing up touched files..."
for f in "${FILES[@]}"; do
  backup "$f"
done

echo "🛠️ Applying auto-fixes..."
python3 - <<'PY'
from pathlib import Path
import re

files = [
  Path("lib/features/agent/listings/create_listing/create_listing_stepper.dart"),
  Path("lib/features/agent/tenancies/tenancy_detail_screen.dart"),
  Path("lib/features/auth/ui/register/register_state.dart"),
  Path("lib/features/agent/listings/create_listing/steps/basics_step.dart"),
  Path("lib/features/agent/listings/create_listing/steps/pricing_step.dart"),
  Path("lib/features/tenant/maintenance/create_request_screen.dart"),
  Path("lib/features/tenant/profile/documents/upload_document_screen.dart"),
]

# 1) Curly braces lint:
#   if (cond) statement;
# -> if (cond) { statement; }
if_one_liner = re.compile(
    r'(^[ \t]*if\s*\([^\)]*\)\s*)(?!\{)([A-Za-z_][^;\n]*;)\s*$',
    re.M
)

# 2) Deprecated "value:" parameter -> "initialValue:" (only if it's a line that starts with value:)
value_param = re.compile(r'(^[ \t]*)value\s*:\s*', re.M)

# 3) Missing @override above "get user"
# Insert @override if we find "get user" and the previous non-empty line isn't @override.
get_user_line = re.compile(r'^[ \t]*[A-Za-z0-9_<>\?]+\s+get\s+user\b', re.M)

def fix_file(p: Path) -> int:
    if not p.exists():
        return 0

    s = p.read_text(encoding="utf-8")
    original = s

    # Curly braces (only makes changes if pattern matches)
    s = if_one_liner.sub(r'\1{ \2 }', s)

    # value: -> initialValue:
    # (Do this only in known files where analyze pointed it out; safe because it only hits lines that start with value:)
    if p.name in {"basics_step.dart", "pricing_step.dart", "create_request_screen.dart", "upload_document_screen.dart"}:
        s = value_param.sub(r'\1initialValue: ', s)

    # Add @override for user getter in register_state.dart
    if p.name == "register_state.dart":
        lines = s.splitlines(True)
        # find line index where getter exists
        for i, ln in enumerate(lines):
            if get_user_line.search(ln):
                # walk backwards to find previous non-empty line
                j = i - 1
                while j >= 0 and lines[j].strip() == "":
                    j -= 1
                prev = lines[j].strip() if j >= 0 else ""
                if prev != "@override":
                    indent = re.match(r'^([ \t]*)', ln).group(1)
                    lines.insert(i, f"{indent}@override\n")
                break
        s = "".join(lines)

    if s != original:
        p.write_text(s, encoding="utf-8")
        return 1
    return 0

changed_files = 0
for p in files:
    changed_files += fix_file(p)

print(f"✅ Updated files: {changed_files}")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
