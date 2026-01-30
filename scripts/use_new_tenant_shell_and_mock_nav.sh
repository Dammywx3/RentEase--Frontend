#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_use_new_shell_$TS"
mkdir -p "$BACKUP_DIR"

backup_file () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "📍 Repo: $ROOT_DIR"
echo "🗂️ Backup dir: $BACKUP_DIR"

ROUTER="lib/app/router/app_router.dart"
TENANT_SHELL="lib/features/tenant/shell/tenant_shell.dart"
TENANT_NAV="lib/core/ui/nav/tenant_bottom_nav.dart"

if [ ! -f "$ROUTER" ]; then
  echo "❌ Missing: $ROUTER"
  exit 1
fi

if [ ! -f "$TENANT_SHELL" ]; then
  echo "❌ Missing: $TENANT_SHELL"
  exit 1
fi

if [ ! -f "$TENANT_NAV" ]; then
  echo "❌ Missing: $TENANT_NAV"
  exit 1
fi

backup_file "$ROUTER"
backup_file "$TENANT_SHELL"
backup_file "$TENANT_NAV"

echo "🛠️ Patch 1: Router -> use TenantShell (NOT TenantAppShell)"
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/app/router/app_router.dart")
s = p.read_text(encoding="utf-8")

# Replace import for tenant_app_shell.dart to tenant_shell.dart
s = re.sub(
    r"import\s+'package:rentease_frontend/features/tenant/shell/tenant_app_shell\.dart';",
    "import 'package:rentease_frontend/features/tenant/shell/tenant_shell.dart';",
    s
)

# Replace builder usage TenantAppShell -> TenantShell
s = re.sub(r"\bTenantAppShell\b", "TenantShell", s)

p.write_text(s, encoding="utf-8")
print("✅ app_router.dart now routes /tenant -> TenantShell()")
PY

echo "🛠️ Patch 2: Make bottom nav match mock (leaf Explore icon + badge on Saved tab)"
python3 - <<'PY'
from pathlib import Path
import re

nav = Path("lib/core/ui/nav/tenant_bottom_nav.dart")
shell = Path("lib/features/tenant/shell/tenant_shell.dart")

s = nav.read_text(encoding="utf-8")

# 1) Rename messagesBadgeCount -> savedBadgeCount (cos mock badge is on Saved)
s = s.replace("messagesBadgeCount", "savedBadgeCount")

# 2) Ensure constructor param comment matches
s = s.replace("/// Set to 0 if you want no badge.", "/// Set to 0 if you want no badge on Saved.")

# 3) Put badgeCount on Saved (index 2) and remove from Messages (index 3)
#   - remove any badgeCount: savedBadgeCount from Messages block if it exists
s = re.sub(r"(label:\s*'Messages'[\s\S]*?)(badgeCount:\s*savedBadgeCount,\s*)", r"\1", s)

#   - ensure Saved has badgeCount: savedBadgeCount
#     (insert after iconActive line inside Saved _Item)
s = re.sub(
    r"(label:\s*'Saved'[\s\S]*?iconActive:\s*Icons\.favorite_rounded,\s*)",
    r"\1                        badgeCount: savedBadgeCount,\n",
    s
)

# 4) Explore icon should look like leaf (eco) like mock
s = s.replace("icon: Icons.explore_outlined,", "icon: Icons.eco_outlined,")
s = s.replace("iconActive: Icons.explore_rounded,", "iconActive: Icons.eco_rounded,")

nav.write_text(s, encoding="utf-8")

# Update TenantShell argument name
ss = shell.read_text(encoding="utf-8")
ss = ss.replace("messagesBadgeCount:", "savedBadgeCount:")
shell.write_text(ss, encoding="utf-8")

print("✅ tenant_bottom_nav.dart updated: Explore leaf icon + Saved badge")
print("✅ tenant_shell.dart updated to pass savedBadgeCount")
PY

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze

echo
echo "✅ Done."
echo "🗂️ Backup saved in: $BACKUP_DIR"
echo
echo "▶️ Now run: flutter clean && flutter pub get && flutter run"
