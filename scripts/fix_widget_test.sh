#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TEST_FILE="test/widget_test.dart"
mkdir -p test

# Try to find your root widget file (common patterns)
CANDIDATES=(
  "lib/app/app.dart"
  "lib/app.dart"
  "lib/app/app_widget.dart"
  "lib/app/my_app.dart"
  "lib/main.dart"
)

FOUND_FILE=""
for f in "${CANDIDATES[@]}"; do
  if [ -f "$f" ]; then
    FOUND_FILE="$f"
    break
  fi
done

# If not found in common paths, search for a file that defines a root widget
if [ -z "$FOUND_FILE" ]; then
  FOUND_FILE="$(grep -RIl --exclude-dir=build --exclude-dir=.dart_tool --include='*.dart' \
    -E 'class\s+(App|MyApp|RentEaseApp)\s+extends\s+(StatelessWidget|StatefulWidget)' lib 2>/dev/null | head -n 1 || true)"
fi

if [ -z "$FOUND_FILE" ]; then
  echo "❌ Couldn't find your root widget file."
  echo "✅ Quick fix: tell me what your root widget class is in lib/main.dart (e.g. MyApp, RentEaseApp)."
  exit 1
fi

echo "✅ Found candidate root file: $FOUND_FILE"

# Detect widget class name from that file
WIDGET_CLASS="$(grep -Eo 'class\s+(App|MyApp|RentEaseApp)\s+extends\s+(StatelessWidget|StatefulWidget)' "$FOUND_FILE" \
  | head -n 1 | awk '{print $2}' || true)"

# If we found main.dart but no class, assume MyApp is used in runApp(...)
if [ -z "$WIDGET_CLASS" ]; then
  WIDGET_CLASS="$(grep -Eo 'runApp\(\s*(const\s+)?[A-Za-z_][A-Za-z0-9_]*' "$FOUND_FILE" \
    | head -n 1 | sed -E 's/runApp\(\s*(const\s+)?//g' || true)"
fi

if [ -z "$WIDGET_CLASS" ]; then
  echo "❌ Couldn't detect root widget class from $FOUND_FILE"
  echo "Open $FOUND_FILE and tell me what you pass into runApp(...)."
  exit 1
fi

echo "✅ Detected root widget: $WIDGET_CLASS"

# Build import path for package import
PKG_NAME="$(grep -E '^\s*name:\s*' pubspec.yaml | head -n 1 | awk '{print $2}' || true)"
if [ -z "$PKG_NAME" ]; then
  echo "❌ Couldn't read package name from pubspec.yaml"
  exit 1
fi

IMPORT_PATH="package:${PKG_NAME}/${FOUND_FILE#lib/}"

echo "🧪 Writing $TEST_FILE using $IMPORT_PATH and widget $WIDGET_CLASS ..."

cat > "$TEST_FILE" <<EOF
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '$IMPORT_PATH';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: $WIDGET_CLASS()));
    await tester.pumpAndSettle();
    expect(find.byType($WIDGET_CLASS), findsOneWidget);
  });
}
EOF

echo "✅ Patched: $TEST_FILE"
echo "🔎 flutter analyze..."
flutter analyze
echo "✅ Done."
