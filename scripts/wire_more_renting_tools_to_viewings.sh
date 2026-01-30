#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_more_wire_$TS"
mkdir -p "$BACKUP_DIR"

FILE="lib/features/tenant/more/more_screen.dart"

# backup
mkdir -p "$BACKUP_DIR/$(dirname "$FILE")"
cp "$FILE" "$BACKUP_DIR/$FILE"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/tenant/more/more_screen.dart")
s = p.read_text(encoding="utf-8")

# 1) Ensure import exists
imp = "import 'package:rentease_frontend/features/tenant/viewings/viewings_screen.dart';\n"
if imp not in s:
    # Insert after material import
    s = re.sub(
        r"(import\s+'package:flutter/material\.dart';\s*\n)",
        r"\1" + imp,
        s,
        flags=re.M,
    )

# 2) Replace the Renting Tools tile onTap
# We match the _MenuTile block where title is 'Renting Tools' and replace only its onTap.
pattern = re.compile(
    r"(_MenuTile\(\s*"
    r"(?:.|\n)*?"
    r"title:\s*'Renting Tools',\s*"
    r"(?:.|\n)*?"
    r"onTap:\s*\(\)\s*=>\s*\{\s*\}\s*,"
    r")",
    re.M,
)

def repl(m):
    block = m.group(1)
    block2 = re.sub(
        r"onTap:\s*\(\)\s*=>\s*\{\s*\}\s*,",
        "onTap: () {\n"
        "                  Navigator.of(context).push(\n"
        "                    MaterialPageRoute(builder: (_) => const ViewingsScreen()),\n"
        "                  );\n"
        "                },",
        block,
        flags=re.M,
    )
    return block2

if pattern.search(s):
    s = pattern.sub(repl, s, count=1)
else:
    # fallback: a simpler replacement if arrow style isn't present
    s2 = s.replace(
        "title: 'Renting Tools',\n                subtitle: 'Tenancies • Applications • Viewings',\n                onTap: () {},",
        "title: 'Renting Tools',\n                subtitle: 'Tenancies • Applications • Viewings',\n                onTap: () {\n"
        "                  Navigator.of(context).push(\n"
        "                    MaterialPageRoute(builder: (_) => const ViewingsScreen()),\n"
        "                  );\n"
        "                },",
    )
    s = s2

p.write_text(s, encoding="utf-8")
print("✅ Renting Tools now navigates to ViewingsScreen + import added (if missing).")
PY

dart format "$FILE" >/dev/null || true
flutter analyze || true

echo
echo "✅ Done. Backup saved in: $BACKUP_DIR"
