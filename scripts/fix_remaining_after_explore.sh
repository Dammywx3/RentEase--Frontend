#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "�� Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_remaining_after_explore_$TS"
mkdir -p "$BACKUP_DIR"

backup () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

FILES_TO_BACKUP=(
  "lib/core/ui/scaffold/app_scaffold.dart"
  "lib/features/tenant/explore/explore_screen.dart"
  "lib/features/tenant/shell/tenant_shell.dart"
  "lib/features/tenant/viewings/viewings_screen.dart"
  "lib/features/agent/tenancies/tenancies_screen.dart"
  "lib/features/agent/listings/create_listing/steps/basics_step.dart"
  "lib/features/agent/listings/create_listing/steps/pricing_step.dart"
)

echo "🗂️ Backing up files..."
for f in "${FILES_TO_BACKUP[@]}"; do backup "$f"; done

echo "🛠️ Patch 1: Add scroll support back to AppScaffold (fixes 'scroll' named param + helps layout)"
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/core/ui/scaffold/app_scaffold.dart")
if not p.exists():
    raise SystemExit("❌ Missing file: lib/core/ui/scaffold/app_scaffold.dart")

s = p.read_text(encoding="utf-8")

# If scroll already exists, skip
if "this.scroll" in s or "final bool scroll" in s:
    print("ℹ️ AppScaffold already supports scroll. Skipping.")
    raise SystemExit(0)

# Replace constructor + fields + build body safely.
# We'll rewrite the whole file to avoid fragile regex edits.
p.write_text(
"""import 'package:flutter/material.dart';

/// AppScaffold
/// - Safely constrains page layout to prevent "RenderBox was not laid out"
/// - Optional background image
/// - Optional topBar widget (your AppTopBar fits here)
/// - scroll=true wraps body in SingleChildScrollView (keeps old API working)
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.topBar,
    this.padding,
    this.backgroundImagePath,
    this.scroll = false,
  });

  final Widget child;
  final Widget? topBar;
  final EdgeInsets? padding;
  final String? backgroundImagePath;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? EdgeInsets.zero;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (backgroundImagePath != null)
              Positioned.fill(
                child: Image.asset(
                  backgroundImagePath!,
                  fit: BoxFit.cover,
                ),
              ),

            // Column + Expanded ensures bounded height.
            Column(
              children: [
                if (topBar != null) topBar!,
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      Widget content = Padding(
                        padding: pad,
                        child: child,
                      );

                      if (scroll) {
                        content = SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: content,
                          ),
                        );
                      }

                      return content;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
""",
    encoding="utf-8",
)
print("✅ AppScaffold updated with scroll support.")
PY

echo "🛠️ Patch 2: Fix Explore lint 'unnecessary_underscores' (replace (_, __, ___) with named args)"
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/tenant/explore/explore_screen.dart")
if not p.exists():
    print("ℹ️ Explore screen not found, skipping.")
    raise SystemExit(0)

s = p.read_text(encoding="utf-8")

# Replace common errorBuilder patterns with named params
s2 = s
s2 = re.sub(r'errorBuilder:\s*\(\s*_,\s*__,\s*___\s*\)\s*=>',
            'errorBuilder: (context, error, stackTrace) =>', s2)
s2 = re.sub(r'errorBuilder:\s*\(\s*_,\s*__\s*,\s*___\s*\)\s*=>',
            'errorBuilder: (context, error, stackTrace) =>', s2)

if s2 != s:
    p.write_text(s2, encoding="utf-8")
    print("✅ Explore errorBuilder underscores fixed.")
else:
    print("ℹ️ No underscore lint patterns found in Explore.")
PY

echo "🛠️ Patch 3: Remove unused import in tenant_shell.dart (profile_screen.dart)"
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/tenant/shell/tenant_shell.dart")
if not p.exists():
    print("ℹ️ tenant_shell.dart not found, skipping.")
    raise SystemExit(0)

s = p.read_text(encoding="utf-8")
s2 = re.sub(r"^\s*import\s+'../profile/profile_screen\.dart';\s*\n", "", s, flags=re.M)

if s2 != s:
    p.write_text(s2, encoding="utf-8")
    print("✅ Removed unused profile import.")
else:
    print("ℹ️ No unused profile import found.")
PY

echo "🛠️ Patch 4: Fix deprecated DropdownButtonFormField value: -> initialValue: in 2 files only"
python3 - <<'PY'
from pathlib import Path
import re

targets = [
    Path("lib/features/agent/listings/create_listing/steps/basics_step.dart"),
    Path("lib/features/agent/listings/create_listing/steps/pricing_step.dart"),
]

changed = 0

for p in targets:
    if not p.exists():
        continue
    s = p.read_text(encoding="utf-8")
    s2 = s

    # Only change DropdownButtonFormField(...) argument 'value:' lines
    # and DO NOT touch DropdownMenuItem(value: ...)
    # So: replace lines that start with whitespace + value: _something,
    s2 = re.sub(r'(?m)^\s*value\s*:\s*(_[A-Za-z0-9]+)\s*,\s*$',
                r'            initialValue: \1,', s2)

    # If they have different indentation, do a safer generic replace for "value: _x," that is NOT inside DropdownMenuItem.
    # We'll do a targeted replace for DropdownButtonFormField blocks by looking for "DropdownButtonFormField" near it.
    if s2 == s:
        # fallback: replace "DropdownButtonFormField<...>(\n\s*value:" pattern
        s2 = re.sub(r'(DropdownButtonFormField<[^>]*>\(\s*\n\s*)value\s*:',
                    r'\1initialValue:', s2)

    if s2 != s:
        p.write_text(s2, encoding="utf-8")
        changed += 1

print(f"✅ Updated DropdownButtonFormField value->initialValue in {changed} file(s).")
PY

echo "🧹 flutter clean (optional but helps after crashes)..."
flutter clean >/dev/null || true

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backup saved in: $BACKUP_DIR"
