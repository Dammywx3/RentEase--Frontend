#!/usr/bin/env bash
set -euo pipefail

echo "== Safe cleanup warnings v2 (with backups) =="

backup() {
  local f="$1"
  if [[ -f "$f" ]]; then
    cp -a "$f" "$f.bak.$(date +%Y%m%d_%H%M%S)"
  fi
}

# --- 1) Remove unused import in agent listing detail screen (matches ' or ")
AGENT_FILE="lib/features/agent/listings/listing_detail_screen.dart"
if [[ -f "$AGENT_FILE" ]]; then
  backup "$AGENT_FILE"
  perl -i -pe 's~^import\s+[\"\x27]\.\./\.\./\.\./core/ui/scaffold/app_top_bar\.dart[\"\x27];\s*\n~~m' "$AGENT_FILE" || true

  # Fix dead null-aware expressions you showed:
  # final s = (widget.listing.status ?? '').toLowerCase();
  perl -i -pe "s/\\(widget\\.listing\\.status\\s*\\?\\?\\s*''\\)\\.toLowerCase\\(\\)/widget.listing.status.toLowerCase()/g" "$AGENT_FILE" || true
  perl -i -pe 's/\(widget\.listing\.status\s*\?\?\s*""\)\.toLowerCase\(\)/widget.listing.status.toLowerCase()/g' "$AGENT_FILE" || true

  echo "✓ cleaned $AGENT_FILE"
fi

# --- 2) Remove unused import in tenancy_detail_screen.dart
TENANCY_DETAIL="lib/features/tenant/tenancy/tenancy_detail_screen.dart"
if [[ -f "$TENANCY_DETAIL" ]]; then
  backup "$TENANCY_DETAIL"
  perl -i -pe 's~^import\s+[\"\x27]\.\./\.\./\.\./core/theme/app_radii\.dart[\"\x27];\s*\n~~m' "$TENANCY_DETAIL" || true
  echo "✓ cleaned $TENANCY_DETAIL"
fi

# --- 3) Remove unnecessary foundation import in apply_flow_screens.dart (matches ' or ")
APPLY_FLOW="lib/features/tenant/applications/apply_flow_screens.dart"
if [[ -f "$APPLY_FLOW" ]]; then
  backup "$APPLY_FLOW"
  perl -i -pe 's~^import\s+[\"\x27]package:flutter/foundation\.dart[\"\x27];\s*\n~~m' "$APPLY_FLOW" || true

  # AppRadii.xs -> your tokens have xxs, so use xxs (safe)
  perl -i -pe 's/AppRadii\.xs\b/AppRadii.xxs/g' "$APPLY_FLOW" || true

  echo "✓ cleaned $APPLY_FLOW"
fi

# --- 4) Fix const PageController (already done but keep idempotent)
RENTING_TOOLS="lib/features/tenant/renting_tools/renting_tools_screen.dart"
if [[ -f "$RENTING_TOOLS" ]]; then
  backup "$RENTING_TOOLS"
  perl -0777 -i -pe 's/final\s+PageController\s+_pc\s*=\s*const\s+PageController\(/final PageController _pc = PageController(/g' "$RENTING_TOOLS" || true

  # Remove invalid centerTitle param usage (your AppTopBar always centers already)
  perl -0777 -i -pe 's/(AppTopBar\([^\)]*)\b,\s*centerTitle\s*:\s*true\s*(,?)/$1$2/g' "$RENTING_TOOLS" || true
  perl -0777 -i -pe 's/(AppTopBar\([^\)]*)\bcenterTitle\s*:\s*true\s*,\s*/$1/g' "$RENTING_TOOLS" || true

  echo "✓ cleaned $RENTING_TOOLS"
fi

# --- 5) Fix tenant listing_detail_screen.dart warnings from your snippet
TENANT_LISTING_DETAIL="lib/features/tenant/listing_detail/listing_detail_screen.dart"
if [[ -f "$TENANT_LISTING_DETAIL" ]]; then
  backup "$TENANT_LISTING_DETAIL"

  # price ?? 0 is dead if price is non-nullable
  perl -i -pe 's/fmtNairaCompact\(widget\.listing\.price\s*\?\?\s*0\)/fmtNairaCompact(widget.listing.price)/g' "$TENANT_LISTING_DETAIL" || true

  # mediaUrls null-check dead if mediaUrls is non-nullable
  # Replace the whole getter body in a safe, minimal way
  perl -0777 -i -pe 's/List<String>\s+get\s+_media\s*\{\s*final\s+urls\s*=\s*widget\.listing\.mediaUrls;\s*if\s*\(urls\s*==\s*null\)\s*return\s*const\s*\[\];\s*return\s*urls\.whereType<String>\(\)\.where\(\(e\)\s*=>\s*e\.trim\(\)\.isNotEmpty\)\.toList\(\);\s*\}/List<String> get _media {\n      final urls = widget.listing.mediaUrls;\n      return urls.where((e) => e.trim().isNotEmpty).toList();\n    }/s' "$TENANT_LISTING_DETAIL" || true

  echo "✓ cleaned $TENANT_LISTING_DETAIL"
fi

echo ""
echo "== Running flutter analyze =="
flutter analyze
