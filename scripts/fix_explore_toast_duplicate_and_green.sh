#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR=".bak_fix_toast_green_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup () {
  local f="$1"
  if [[ -f "$f" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

backup "lib/features/tenant/explore/explore_screen.dart"
backup "lib/features/tenant/viewings/viewing_detail_screen.dart"

python3 - <<'PY'
from pathlib import Path
import re

# ---------------------------
# 1) explore_screen.dart: remove duplicate _toast + remove _openViewings helper
#    (your file already has direct ViewingsScreen pushes at lines ~272/284)
# ---------------------------
p = Path("lib/features/tenant/explore/explore_screen.dart")
if p.exists():
    s = p.read_text(encoding="utf-8")

    # Remove the stub toast that was inserted: void _toast(String msg){ // ... }
    s = re.sub(
        r"\n\s*void\s+_toast\s*\(\s*String\s+msg\s*\)\s*\{\s*\n\s*//\s*\.\.\.\s*\n\s*\}\s*\n",
        "\n",
        s,
        flags=re.MULTILINE,
    )

    # Remove ANY _openViewings helper method (unused now)
    s = re.sub(
        r"\n\s*void\s+_openViewings\s*\(\s*\)\s*\{[\s\S]*?\n\s*\}\s*\n",
        "\n",
        s,
        flags=re.MULTILINE,
    )

    # If there are STILL two _toast methods, keep the LAST one and delete earlier ones.
    matches = list(re.finditer(r"\n\s*void\s+_toast\s*\(\s*String\s+msg\s*\)\s*\{", s))
    if len(matches) > 1:
        # find start indexes of each toast
        starts = [m.start() for m in matches]
        # remove all but the last by cutting chunks
        last_start = starts[-1]
        prefix = s[:last_start]
        suffix = s[last_start:]

        # delete earlier toast method bodies from prefix
        # repeatedly remove first toast method from prefix
        while True:
            m = re.search(r"\n\s*void\s+_toast\s*\(\s*String\s+msg\s*\)\s*\{", prefix)
            if not m:
                break
            # remove from this start to the matching closing brace line
            cut_start = m.start()
            # naive but reliable: remove until the next "\n  }\n" at same indent level
            # We'll remove until first occurrence of "\n  }\n" after cut_start.
            tail = prefix[cut_start:]
            end = re.search(r"\n\s*\}\s*\n", tail)
            if not end:
                # if we can't find end, stop
                break
            cut_end = cut_start + end.end()
            prefix = prefix[:cut_start] + "\n" + prefix[cut_end:]

        s = prefix + suffix

    p.write_text(s, encoding="utf-8")


# ---------------------------
# 2) viewing_detail_screen.dart: fix undefined _green by replacing uses with actual color
# ---------------------------
p = Path("lib/features/tenant/viewings/viewing_detail_screen.dart")
if p.exists():
    s = p.read_text(encoding="utf-8")
    s = s.replace("_green", "const Color(0xFF3C7C5A)")
    p.write_text(s, encoding="utf-8")

print("✅ Fixed explore duplicate _toast/_openViewings + restored green color usage.")
PY

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backup saved in: $BACKUP_DIR"
