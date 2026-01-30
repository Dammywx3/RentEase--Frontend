#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=".bak_patch_viewings_explore_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup () {
  local f="$1"
  if [[ -f "$f" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

backup "lib/features/tenant/more/more_screen.dart"
backup "lib/features/tenant/viewings/viewing_detail_screen.dart"
backup "lib/features/tenant/viewings/viewings_screen.dart"
backup "lib/features/tenant/explore/explore_screen.dart"

python3 - <<'PY'
from pathlib import Path
import re

# --------------------------
# 1) FIX MoreScreen unused import:
#   - Ensure Renting Tools tile actually navigates to RentingToolsScreen
# --------------------------
p = Path("lib/features/tenant/more/more_screen.dart")
if p.exists():
    s = p.read_text(encoding="utf-8")

    # ensure import exists
    if "renting_tools_screen.dart" not in s:
        s = s.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\nimport '../renting_tools/renting_tools_screen.dart';"
        )

    # replace Renting Tools tile onTap with navigation (robust)
    # looks for: title: 'Renting Tools' ... onTap: () {},
    s2 = re.sub(
        r"(title:\s*'Renting Tools'.*?\n)(\s*)onTap:\s*\(\)\s*\{\s*\},",
        r"\1\2onTap: () {\n\2  Navigator.of(context).push(\n\2    MaterialPageRoute(builder: (_) => const RentingToolsScreen()),\n\2  );\n\2},",
        s,
        flags=re.DOTALL,
    )

    # if nothing changed, maybe the tile is slightly different. Try a simpler match:
    if s2 == s:
        s2 = re.sub(
            r"(title:\s*'Renting Tools'.*?\n)(\s*)onTap:\s*\(\)\s*\{\s*\}",
            r"\1\2onTap: () {\n\2  Navigator.of(context).push(\n\2    MaterialPageRoute(builder: (_) => const RentingToolsScreen()),\n\2  );\n\2}",
            s,
            flags=re.DOTALL,
        )

    s = s2
    p.write_text(s, encoding="utf-8")


# --------------------------
# 2) FIX ViewingDetailScreen unused field _green:
#    - remove it if unused
# --------------------------
p = Path("lib/features/tenant/viewings/viewing_detail_screen.dart")
if p.exists():
    s = p.read_text(encoding="utf-8")

    # remove ONLY the exact unused constant line if present
    s = re.sub(r"^\s*static const _green = Color\(0xFF3C7C5A\);\s*\n", "", s, flags=re.MULTILINE)

    p.write_text(s, encoding="utf-8")


# --------------------------
# 3) FIX ViewingsScreen unnecessary underscores:
#    - replace (_, __) => with (context, index) =>
# --------------------------
p = Path("lib/features/tenant/viewings/viewings_screen.dart")
if p.exists():
    s = p.read_text(encoding="utf-8")

    s = s.replace("separatorBuilder: (_, __) =>", "separatorBuilder: (context, index) =>")
    s = s.replace("itemBuilder: (context, i) {", "itemBuilder: (context, i) {")  # no-op, keep stable

    p.write_text(s, encoding="utf-8")


# --------------------------
# 4) Explore: when Viewings is clicked -> open ViewingsScreen
#    - add _openViewings() if missing
#    - replace common toast taps for Viewings with _openViewings()
# --------------------------
p = Path("lib/features/tenant/explore/explore_screen.dart")
if p.exists():
    s = p.read_text(encoding="utf-8")

    # Ensure helper exists
    if "void _openViewings(" not in s:
        insert_after = "  void _toast(String msg) {\n"
        if insert_after in s:
            s = s.replace(
                insert_after,
                insert_after
                + "    // ...\n"
                + "  }\n\n"
                + "  void _openViewings() {\n"
                + "    Navigator.of(context).push(\n"
                + "      MaterialPageRoute(builder: (_) => const ViewingsScreen()),\n"
                + "    );\n"
                + "  }\n\n"
                + "  void _toast(String msg) {\n"
            )
        else:
            # fallback: append method near end of State class, before build if possible
            s = re.sub(
                r"(\n\s*@override\s*Widget build\()",
                "\n  void _openViewings() {\n"
                "    Navigator.of(context).push(\n"
                "      MaterialPageRoute(builder: (_) => const ViewingsScreen()),\n"
                "    );\n"
                "  }\n\n\\1",
                s
            )

    # Replace common viewings toasts
    patterns = [
        r"onTap:\s*\(\)\s*=>\s*_toast\('Viewings'\)",
        r"onTap:\s*\(\)\s*=>\s*_toast\('My Viewings'\)",
        r"onTap:\s*\(\)\s*=>\s*_toast\(\"Viewings\"\)",
        r"onTap:\s*\(\)\s*=>\s*_toast\(\"My Viewings\"\)",
    ]
    for pat in patterns:
        s = re.sub(pat, "onTap: _openViewings", s)

    # Also handle blocks: onTap: () { _toast('Viewings'); }
    s = re.sub(
        r"onTap:\s*\(\)\s*\{\s*_toast\('Viewings'\);\s*\}",
        "onTap: _openViewings",
        s
    )
    s = re.sub(
        r"onTap:\s*\(\)\s*\{\s*_toast\('My Viewings'\);\s*\}",
        "onTap: _openViewings",
        s
    )

    p.write_text(s, encoding="utf-8")

print("✅ Patch applied.")
PY

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backup saved in: $BACKUP_DIR"
