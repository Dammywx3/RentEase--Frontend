#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_withvalues_alpha_$TS"
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

echo "🛠️ Fixing withValues(alpha: ((255 * X).round())) -> withValues(alpha: X) ..."

# Handles patterns like:
#   withValues(alpha: ((255 * (0.25)).round()))
#   withValues(alpha: ((255 * (.45)).round()))
#   withValues(alpha: ((255 * (someVar)).round()))
perl -0777 -i -pe '
  s/withValues\(\s*alpha:\s*\(\(\s*255\s*\*\s*\(?([^)]+?)\)?\s*\)\s*\.round\(\)\s*\)\s*\)/withValues(alpha: ($1))/g;
' $(find lib -type f -name '*.dart')

echo "🎨 dart format..."
dart format lib test >/dev/null

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
