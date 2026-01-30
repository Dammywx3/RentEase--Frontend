#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_flutter_lints_$TS"
mkdir -p "$BACKUP_DIR"

backup () {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

echo "📍 Repo: $ROOT_DIR"
echo "🗂️ Backup dir: $BACKUP_DIR"

backup "pubspec.yaml"
backup "analysis_options.yaml"

# 1) Ensure flutter_lints is in dev_dependencies
python3 - <<'PY'
from pathlib import Path
import re

p = Path("pubspec.yaml")
if not p.exists():
    raise SystemExit("❌ pubspec.yaml not found")

s = p.read_text(encoding="utf-8")

# If already present, do nothing
if re.search(r'(?m)^\s*flutter_lints\s*:\s*', s):
    print("ℹ️ flutter_lints already in pubspec.yaml")
    raise SystemExit(0)

# Ensure dev_dependencies exists
if not re.search(r'(?m)^dev_dependencies:\s*$', s):
    # Add dev_dependencies near bottom
    s = s.rstrip() + "\n\ndev_dependencies:\n  flutter_lints: ^3.0.1\n"
    p.write_text(s, encoding="utf-8")
    print("✅ Added dev_dependencies + flutter_lints")
    raise SystemExit(0)

# Insert flutter_lints under dev_dependencies
lines = s.splitlines(True)
out = []
inserted = False
in_dev = False
dev_indent = ""

for i, line in enumerate(lines):
    out.append(line)
    if re.match(r'^dev_dependencies:\s*$', line):
        in_dev = True
        dev_indent = re.match(r'^(\s*)', line).group(1)
        continue

    if in_dev:
        # End of dev_dependencies when a new top-level key starts
        if re.match(r'^[A-Za-z_][A-Za-z0-9_]*\s*:', line) and not line.startswith(dev_indent + " "):
            # Insert before this new section
            out.insert(len(out)-1, f"{dev_indent}  flutter_lints: ^3.0.1\n")
            inserted = True
            in_dev = False

# If dev_dependencies was last section
if in_dev and not inserted:
    out.append(f"{dev_indent}  flutter_lints: ^3.0.1\n")
    inserted = True

if not inserted:
    raise SystemExit("❌ Could not insert flutter_lints automatically")

p.write_text("".join(out), encoding="utf-8")
print("✅ Inserted flutter_lints into dev_dependencies")
PY

# 2) If analysis_options.yaml references flutter_lints include, keep it.
# If it doesn't exist, create a minimal one.
if [ ! -f analysis_options.yaml ]; then
  cat > analysis_options.yaml <<'YAML'
include: package:flutter_lints/flutter.yaml

linter:
  rules:
YAML
  echo "✅ Created analysis_options.yaml"
else
  # Make sure include line exists (don’t duplicate)
  if ! grep -q "package:flutter_lints/flutter.yaml" analysis_options.yaml; then
    # prepend include
    tmp="$(mktemp)"
    {
      echo "include: package:flutter_lints/flutter.yaml"
      echo
      cat analysis_options.yaml
    } > "$tmp"
    mv "$tmp" analysis_options.yaml
    echo "✅ Prepended flutter_lints include to analysis_options.yaml"
  else
    echo "ℹ️ analysis_options.yaml already includes flutter_lints"
  fi
fi

echo "📦 flutter pub get..."
flutter pub get

echo "🔎 flutter analyze..."
flutter analyze || true

echo "✅ Done. Backups: $BACKUP_DIR"
