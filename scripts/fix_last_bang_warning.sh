#!/usr/bin/env bash
set -euo pipefail

FILE="lib/features/tenant/listing_detail/listing_detail_screen.dart"

echo "== Fix last unnecessary ! warning =="

if [[ ! -f "$FILE" ]]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

cp -a "$FILE" "$FILE.bak.$(date +%Y%m%d_%H%M%S)"

# Remove non-null assertion (!) on known listing fields (handles title!.trim(), ownerName!.trim(), location!.trim())
perl -i -pe 's/widget\.listing\.(title|ownerName|location)!/widget.listing.$1/g' "$FILE"

echo "✓ patched $FILE"
echo ""
echo "== Running flutter analyze =="
flutter analyze
