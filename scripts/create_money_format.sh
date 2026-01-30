#!/usr/bin/env bash
set -euo pipefail

FILE="lib/core/utils/money_format.dart"
DIR="$(dirname "$FILE")"

mkdir -p "$DIR"

cat > "$FILE" <<'DART'
/// Shared money formatting helpers.
/// Keep UI screens clean by using shared formatters.

/// Formats 1200000 -> ₦1,200,000
String fmtNaira(num v) {
  final s = v.toInt().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idxFromEnd = s.length - i;
    buf.write(s[i]);
    if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
  }
  return '₦$buf';
}

/// Formats 1200000 -> ₦1.2M (optional helper)
String fmtNairaCompact(num v) {
  final n = v.toDouble();
  if (n >= 1000000000) return '₦${(n / 1000000000).toStringAsFixed(1)}B';
  if (n >= 1000000) return '₦${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '₦${(n / 1000).toStringAsFixed(1)}K';
  return fmtNaira(n);
}
DART

echo "✅ Created: $FILE"
