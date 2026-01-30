#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-lib/features/tenant}"
OUT="${2:-tenant_dump.txt}"

if [[ ! -d "$ROOT" ]]; then
  echo "❌ Folder not found: $ROOT"
  exit 1
fi

echo "✅ Dumping Dart files from: $ROOT"
echo "➡️ Output: $OUT"

# Make a stable, readable dump: file header + content
: > "$OUT"

# You can add more folders here if you want:
# EXTRA=("lib/core/theme" "lib/core/ui/scaffold" "lib/core/utils")
EXTRA=()

dump_one() {
  local base="$1"
  find "$base" -type f -name "*.dart" | LC_ALL=C sort | while read -r f; do
    {
      echo "/* ====================================================================="
      echo "   FILE: $f"
      echo "   ===================================================================== */"
      echo
      cat "$f"
      echo
      echo
    } >> "$OUT"
  done
}

dump_one "$ROOT"
for x in "${EXTRA[@]}"; do
  [[ -d "$x" ]] && dump_one "$x"
done

echo "✅ Done. Upload: $OUT"
