#!/usr/bin/env bash
set -euo pipefail

FILE="lib/features/tenant/listing_detail/listing_detail_screen.dart"

echo "== Fix nullable .trim() in listing_detail_screen.dart =="

if [[ ! -f "$FILE" ]]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

cp -a "$FILE" "$FILE.bak.$(date +%Y%m%d_%H%M%S)"

# Safely wrap .title/.location/.ownerName before calling trim()
# Only affects the exact patterns that cause analyzer errors.
perl -i -pe "s/widget\\.listing\\.title\\.trim\\(\\)/(widget.listing.title ?? '').trim()/g" "$FILE"
perl -i -pe "s/widget\\.listing\\.location\\.trim\\(\\)/(widget.listing.location ?? '').trim()/g" "$FILE"
perl -i -pe "s/widget\\.listing\\.ownerName\\.trim\\(\\)/(widget.listing.ownerName ?? '').trim()/g" "$FILE"

echo "✓ patched $FILE"
echo ""
echo "== Running flutter analyze =="
flutter analyze
