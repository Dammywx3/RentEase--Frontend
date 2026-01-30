#!/usr/bin/env bash
set -euo pipefail

echo "== Safe cleanup warnings =="

# 1) Remove unused import in agent listing_detail_screen.dart
AGENT_FILE="lib/features/agent/listings/listing_detail_screen.dart"
if [[ -f "$AGENT_FILE" ]]; then
  # remove only the app_top_bar import line
  perl -0777 -i -pe "s~^import\\s+'\\.{3}/\\.{3}/core/ui/scaffold/app_top_bar\\.dart';\\s*\\n~~mg" "$AGENT_FILE" || true
  echo "✓ cleaned unused import in $AGENT_FILE"
fi

# 2) Remove unused AppRadii import in tenancy_detail_screen.dart
TENANCY_DETAIL="lib/features/tenant/tenancy/tenancy_detail_screen.dart"
if [[ -f "$TENANCY_DETAIL" ]]; then
  perl -0777 -i -pe "s~^import\\s+'\\.{3}/\\.{3}/core/theme/app_radii\\.dart';\\s*\\n~~mg" "$TENANCY_DETAIL" || true
  echo "✓ cleaned unused import in $TENANCY_DETAIL"
fi

# 3) Remove unnecessary foundation import in apply_flow_screens.dart
APPLY_FLOW="lib/features/tenant/applications/apply_flow_screens.dart"
if [[ -f "$APPLY_FLOW" ]]; then
  perl -0777 -i -pe "s~^import\\s+'package:flutter/foundation\\.dart';\\s*\\n~~mg" "$APPLY_FLOW" || true
  echo "✓ removed unnecessary foundation import in $APPLY_FLOW"
fi

# 4) Fix const PageController issue in renting_tools_screen.dart
RENTING_TOOLS="lib/features/tenant/renting_tools/renting_tools_screen.dart"
if [[ -f "$RENTING_TOOLS" ]]; then
  # Replace: final PageController _pc = const PageController(...)
  # With:    final PageController _pc = PageController(...)
  perl -0777 -i -pe "s/final\\s+PageController\\s+_pc\\s*=\\s*const\\s+PageController\\(/final PageController _pc = PageController(/g" "$RENTING_TOOLS" || true
  echo "✓ fixed PageController const in $RENTING_TOOLS"
fi

echo ""
echo "== Running flutter analyze =="
flutter analyze
