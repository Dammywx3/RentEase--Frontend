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

echo "🛠️ Fixing .withValues(alpha: <int 0-255>) -> .withValues(alpha: <double 0-1>) ..."

# Convert alpha ints to alpha doubles: alpha: 64 -> alpha: 0.25098039215686274
perl -0777 -i -pe '
  s/withValues\(\s*alpha:\s*([0-9]{1,3})\s*\)/
    "withValues(alpha: " . ($1/255) . ")"
/ge;
' $(find lib -type f -name '*.dart')

echo "🎨 dart format..."
dart format lib test >/dev/null

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
