#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

PKG_NAME="$(grep -E '^\s*name:\s*' pubspec.yaml | head -n 1 | awk '{print $2}' || true)"
if [ -z "${PKG_NAME:-}" ]; then
  echo "❌ Could not read package name from pubspec.yaml"
  exit 1
fi

MAIN_FILE="lib/main.dart"
if [ ! -f "$MAIN_FILE" ]; then
  echo "❌ $MAIN_FILE not found."
  exit 1
fi

# Extract widget class from runApp(...)
# Matches: runApp(const MyApp()); OR runApp(MyApp());
ROOT_WIDGET="$(grep -Eo 'runApp\(\s*(const\s+)?[A-Za-z_][A-Za-z0-9_]*' "$MAIN_FILE" \
  | head -n 1 \
  | sed -E 's/runApp\(\s*(const\s+)?//g' || true)"

if [ -z "${ROOT_WIDGET:-}" ]; then
  echo "❌ Couldn't detect root widget from runApp(...) in $MAIN_FILE"
  echo "Open $MAIN_FILE and make sure it has: runApp(MyWidget());"
  exit 1
fi

echo "✅ Detected root widget from main.dart: $ROOT_WIDGET"

# Find where the widget class is defined
DEF_FILE="$(grep -RIl --exclude-dir=build --exclude-dir=.dart_tool --include='*.dart' \
  -E "class\s+${ROOT_WIDGET}\s+extends\s+(StatelessWidget|StatefulWidget)" lib | head -n 1 || true)"

if [ -z "${DEF_FILE:-}" ]; then
  echo "⚠️ Couldn't find class definition for $ROOT_WIDGET in lib/"
  echo "I'll import main.dart directly and use $ROOT_WIDGET() anyway."
  DEF_FILE="lib/main.dart"
fi

IMPORT_PATH="package:${PKG_NAME}/${DEF_FILE#lib/}"
echo "✅ Using import: $IMPORT_PATH"

# Check if it has a const constructor usage in its defining file
USE_CONST=""
if grep -qE "const\s+${ROOT_WIDGET}\s*\(" "$DEF_FILE"; then
  USE_CONST="const "
fi

TEST_FILE="test/widget_test.dart"
mkdir -p test

cat > "$TEST_FILE" <<EOF
import 'package:flutter_test/flutter_test.dart';
import '$IMPORT_PATH';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(${USE_CONST}${ROOT_WIDGET}());
    await tester.pumpAndSettle();
    expect(find.byType(${ROOT_WIDGET}), findsOneWidget);
  });
}
EOF

echo "✅ Patched: $TEST_FILE"
echo "🔎 flutter analyze..."
flutter analyze
echo "✅ Done."
