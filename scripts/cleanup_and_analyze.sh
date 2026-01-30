#!/usr/bin/env bash
set -euo pipefail

# Run from repo root even if executed from scripts/
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

# 1) Remove debug bundle folders that are polluting flutter analyze
echo "🧹 Removing rentease_debug_bundle_* folders (if any)..."
find . -maxdepth 2 -type d -name "rentease_debug_bundle_*" -print -exec rm -rf {} + || true

# 2) Add to .gitignore so it never happens again
if [ -f .gitignore ]; then
  if ! grep -q '^rentease_debug_bundle_\*/' .gitignore; then
    echo "" >> .gitignore
    echo "# Local debug bundles (do not commit)" >> .gitignore
    echo "rentease_debug_bundle_*/" >> .gitignore
    echo "✅ Updated .gitignore"
  else
    echo "ℹ️ .gitignore already contains rentease_debug_bundle_*/"
  fi
else
  echo "⚠️ .gitignore not found, creating one..."
  cat > .gitignore <<'EOF'
# Local debug bundles (do not commit)
rentease_debug_bundle_*/
EOF
  echo "✅ Created .gitignore"
fi

# 3) (Optional) remove the default widget test if your root widget isn't MyApp
# This stops: "The name 'MyApp' isn't a class • test/widget_test.dart..."
if [ -f test/widget_test.dart ]; then
  echo "🧪 Patching test/widget_test.dart to use your App widget (instead of MyApp)..."
  cat > test/widget_test.dart <<'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// Adjust this import if your root widget path is different:
import 'package:rentease_frontend/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: App()));
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}
EOF
  echo "✅ Patched: test/widget_test.dart"
else
  echo "ℹ️ No test/widget_test.dart found (skipping)"
fi

# 4) Get deps + analyze
echo "📦 flutter pub get..."
flutter pub get

echo "🔎 flutter analyze..."
flutter analyze

echo ""
echo "✅ Done. If there are STILL errors now, paste ONLY the remaining errors (not info/warnings)."
