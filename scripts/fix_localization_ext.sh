#!/usr/bin/env bash
set -euo pipefail

FILE="lib/core/utils/localization_ext.dart"
mkdir -p "$(dirname "$FILE")"

cat > "$FILE" <<'DART'
import 'package:flutter/material.dart';

extension MaterialLocalizationsX on MaterialLocalizations {
  /// Flutter does not provide formatShortWeekday. We supply a stable Mon..Sun mapping.
  String shortWeekday(DateTime d) {
    const w = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final idx = (d.weekday - 1) % 7;
    return w[idx];
  }
}
DART

echo "✅ Rewrote $FILE"
echo "Running flutter analyze..."
flutter analyze
