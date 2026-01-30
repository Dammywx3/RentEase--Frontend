#!/usr/bin/env bash
set -euo pipefail

FILE="lib/features/tenant/listing_detail/listing_detail_screen.dart"

echo "== Fix last error/warning in listing_detail_screen.dart =="

if [[ ! -f "$FILE" ]]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

cp -a "$FILE" "$FILE.bak.$(date +%Y%m%d_%H%M%S)"

# 1) Fix nullable .trim() (most likely ownerName)
# Convert: widget.listing.ownerName.trim() -> (widget.listing.ownerName ?? '').trim()
perl -i -pe "s/widget\\.listing\\.ownerName\\.trim\\(\\)/(widget.listing.ownerName ?? '').trim()/g" "$FILE"

# 2) Remove any remaining useless non-null assertions on listing fields in this file
perl -i -pe 's/widget\.listing\.(title|ownerName|location)!\b/widget.listing.$1/g' "$FILE"

echo "✓ patched $FILE"
echo ""
echo "== Running flutter analyze =="
flutter analyze
