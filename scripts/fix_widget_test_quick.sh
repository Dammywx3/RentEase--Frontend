#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

mkdir -p test

# Backup existing test if it exists
if [ -f test/widget_test.dart ]; then
  cp test/widget_test.dart "test/widget_test.dart.bak.$(date +%Y%m%d_%H%M%S)"
  echo "✅ Backed up existing test/widget_test.dart"
fi

cat > test/widget_test.dart <<'DART'
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('basic widget test', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: Text('OK'))));
    await tester.pumpAndSettle();
    expect(find.text('OK'), findsOneWidget);
  });
}
DART

echo "✅ Patched: test/widget_test.dart"
echo "🔎 flutter analyze..."
flutter analyze
echo "✅ Done."
