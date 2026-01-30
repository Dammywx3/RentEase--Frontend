#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_switch_shell_$TS"
mkdir -p "$BACKUP_DIR"

backup_file () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "📍 Repo: $ROOT_DIR"
echo "🗂️ Backing up..."
backup_file "lib/app/router/app_router.dart"
backup_file "lib/features/tenant/explore/explore_screen.dart"

echo "🛠️ Patch: app_router.dart to use TenantShell"
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/app/router/app_router.dart")
s = p.read_text(encoding="utf-8")

# Replace import of tenant_app_shell.dart -> tenant_shell.dart
s2 = s

# If they import tenant_app_shell.dart, swap to tenant_shell.dart
s2 = re.sub(
    r"import\s+'package:rentease_frontend/features/tenant/shell/tenant_app_shell\.dart';",
    "import 'package:rentease_frontend/features/tenant/shell/tenant_shell.dart';",
    s2
)

# Replace TenantAppShell() usage with TenantShell()
s2 = re.sub(r"\bTenantAppShell\s*\(", "TenantShell(", s2)

# If the import wasn't there (maybe relative), add a safe import for tenant_shell.dart
if "tenant_shell.dart" not in s2:
    # Insert after routes import
    s2 = re.sub(
        r"(import\s+'routes\.dart';\s*\n)",
        r"\1import 'package:rentease_frontend/features/tenant/shell/tenant_shell.dart';\n",
        s2
    )
    # Also try removing tenant_app_shell import if exists
    s2 = re.sub(r"^.*tenant_app_shell\.dart.*\n", "", s2, flags=re.M)

p.write_text(s2, encoding="utf-8")
print("✅ app_router.dart now points tenant shell route to TenantShell.")
PY

echo "🛠️ Patch: remove unused _green/_blue in explore_screen.dart"
python3 - <<'PY'
from pathlib import Path
import re

p = Path("lib/features/tenant/explore/explore_screen.dart")
s = p.read_text(encoding="utf-8")

# Remove the two unused static const lines if they exist
s2 = re.sub(r"^\s*static const _green = .*;\s*\n", "", s, flags=re.M)
s2 = re.sub(r"^\s*static const _blue = .*;\s*\n", "", s2, flags=re.M)

p.write_text(s2, encoding="utf-8")
print("✅ explore_screen.dart unused constants removed.")
PY

echo "🎨 dart format..."
dart format lib >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backup saved in: $BACKUP_DIR"
