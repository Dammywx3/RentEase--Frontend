#!/usr/bin/env bash
set -euo pipefail

echo "== Cleanup remaining warnings v3 (with backups) =="

backup() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a "$f" "$f.bak.$(date +%Y%m%d_%H%M%S)"
  fi
}

TENANT_LISTING_DETAIL="lib/features/tenant/listing_detail/listing_detail_screen.dart"
if [[ -f "$TENANT_LISTING_DETAIL" ]]; then
  backup "$TENANT_LISTING_DETAIL"

  # ---- Remove dead null-aware expressions where fields are non-nullable ----
  # title/location/ownerName are non-nullable in your analyzer’s eyes, so remove ?? '' and !.
  perl -i -pe "s/\\(widget\\.listing\\.title\\s*\\?\\?\\s*''\\)/widget.listing.title/g" "$TENANT_LISTING_DETAIL" || true
  perl -i -pe 's/\(widget\.listing\.title\s*\?\?\s*""\)/widget.listing.title/g' "$TENANT_LISTING_DETAIL" || true

  perl -i -pe "s/\\(widget\\.listing\\.location\\s*\\?\\?\\s*''\\)/widget.listing.location/g" "$TENANT_LISTING_DETAIL" || true
  perl -i -pe 's/\(widget\.listing\.location\s*\?\?\s*""\)/widget.listing.location/g' "$TENANT_LISTING_DETAIL" || true

  perl -i -pe "s/\\(widget\\.listing\\.ownerName\\s*\\?\\?\\s*''\\)/widget.listing.ownerName/g" "$TENANT_LISTING_DETAIL" || true
  perl -i -pe 's/\(widget\.listing\.ownerName\s*\?\?\s*""\)/widget.listing.ownerName/g' "$TENANT_LISTING_DETAIL" || true

  # Remove useless non-null assertions (title! / ownerName!)
  perl -i -pe 's/widget\.listing\.title!\b/widget.listing.title/g' "$TENANT_LISTING_DETAIL" || true
  perl -i -pe 's/widget\.listing\.ownerName!\b/widget.listing.ownerName/g' "$TENANT_LISTING_DETAIL" || true
  perl -i -pe 's/widget\.listing\.location!\b/widget.listing.location/g' "$TENANT_LISTING_DETAIL" || true

  # ---- Fix a common pattern from your snippet: ----
  # title.isEmpty ? 'Listing' : title  (keep)
  # but title was built from (widget.listing.title ?? '').trim() => now widget.listing.title.trim()
  perl -i -pe "s/final\\s+title\\s*=\\s*\\(widget\\.listing\\.title\\s*\\?\\?\\s*''\\)\\.trim\\(\\);/final title = widget.listing.title.trim();/g" "$TENANT_LISTING_DETAIL" || true
  perl -i -pe "s/final\\s+location\\s*=\\s*\\(widget\\.listing\\.location\\s*\\?\\?\\s*''\\)\\.trim\\(\\);/final location = widget.listing.location.trim();/g" "$TENANT_LISTING_DETAIL" || true

  # ---- Fix dead code spots caused by "if (x == null)" where x is non-nullable ----
  # We already replaced _media getter earlier, but if any "== null" checks remain for non-nullables:
  perl -i -pe 's/\s*if\s*\(\s*widget\.listing\.mediaUrls\s*==\s*null\s*\)\s*return\s+const\s+\[\];\s*\n//g' "$TENANT_LISTING_DETAIL" || true

  echo "✓ cleaned $TENANT_LISTING_DETAIL"
fi

# Optional: fix the curly braces info (safe, does not change logic)
REGISTER="lib/features/auth/ui/register/register_screen.dart"
if [[ -f "$REGISTER" ]]; then
  backup "$REGISTER"
  # Convert: if (cond) doThing();  -> if (cond) { doThing(); }
  # This is best-effort and only touches single-line if statements.
  perl -i -pe 's/^\s*if\s*\(([^)]+)\)\s*([^{;\n]+;)\s*$/if ($1) { $2 }/mg' "$REGISTER" || true
  echo "✓ cleaned $REGISTER (curly braces best-effort)"
fi

echo ""
echo "== Running flutter analyze =="
flutter analyze
