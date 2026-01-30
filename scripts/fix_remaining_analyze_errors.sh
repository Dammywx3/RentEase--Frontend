#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

say() { printf "\n\033[1;36m%s\033[0m\n" "$*"; }
die() { printf "\n\033[1;31mERROR:\033[0m %s\n" "$*" >&2; exit 1; }
need_file() { [[ -f "$1" ]] || die "Missing file: $1"; }

say "Project: $ROOT"
say "Fixing remaining flutter analyze errors..."

SCHEDULE="lib/features/tenant/listing_detail/schedule_visit_screen.dart"
MAINT="lib/features/tenant/maintenance/maintenance_screen.dart"
LOCEXT="lib/core/utils/localization_ext.dart"

need_file "$SCHEDULE"
need_file "$MAINT"

# 1) Ensure localization_ext.dart exists and defines shortWeekday(dt)
if [[ ! -f "$LOCEXT" ]]; then
  say "Creating: $LOCEXT"
  mkdir -p "$(dirname "$LOCEXT")"
  cat > "$LOCEXT" <<'DART'
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
else
  # Append extension only if missing
  if ! rg -n "extension\s+MaterialLocalizationsX\s+on\s+MaterialLocalizations" "$LOCEXT" >/dev/null 2>&1; then
    say "Appending MaterialLocalizationsX.shortWeekday to $LOCEXT"
    cat >> "$LOCEXT" <<'DART'

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
  fi
fi

# 2) schedule_visit_screen.dart: ensure it imports localization_ext.dart (it already does, but keep it)
if ! rg -n "core/utils/localization_ext\.dart" "$SCHEDULE" >/dev/null 2>&1; then
  say "Adding import of localization_ext.dart to schedule_visit_screen.dart"
  perl -0777 -i -pe 's@(import\s+\\x27package:flutter/material\\.dart\\x27;\\s*)@$1\nimport \x27../../../core/utils/localization_ext.dart\x27;\n@' "$SCHEDULE"
fi

# 3) Replace _shortWeekday(loc, dt) calls with loc.shortWeekday(dt)
say "Updating _shortWeekday(...) calls -> loc.shortWeekday(...) in schedule_visit_screen.dart"
perl -0777 -i -pe 's/_shortWeekday\s*\(\s*loc\s*,\s*([^)]+)\)/loc.shortWeekday($1)/g' "$SCHEDULE"

# 4) Remove any inserted _shortWeekday helper methods (optional cleanup). Not required, but avoids confusion.
# This removes a method block like:
# String _shortWeekday(MaterialLocalizations loc, DateTime d) { ... }
say "Removing any leftover _shortWeekday helper method blocks (if present)"
perl -0777 -i -pe 's/\n\s*String\s+_shortWeekday\s*\(\s*MaterialLocalizations\s+loc\s*,\s*DateTime\s+d\s*\)\s*\{.*?\n\s*\}\n//sg' "$SCHEDULE"

# 5) Fix maintenance_screen.dart: String? -> String for priorityText
# Current code (from your paste):
# priorityText: x.priority == null ? null : 'Priority: ${x.priority}',
# But MaintenanceCard expects String. Make it always a string.
say "Fixing maintenance_screen.dart: priorityText must be String"
perl -0777 -i -pe "s/priorityText:\\s*x\\.priority\\s*==\\s*null\\s*\\?\\s*null\\s*:\\s*'Priority:\\s*\\$\\{x\\.priority\\}',/priorityText: x.priority == null ? '' : 'Priority: \\$\\{x.priority\\}',/g" "$MAINT"

say "✅ Patches applied."
say "Run:"
echo "flutter analyze"
echo "flutter run"
