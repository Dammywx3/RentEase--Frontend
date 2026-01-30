#!/usr/bin/env bash
set -euo pipefail

# Safe if accidentally sourced
_is_sourced() { [[ "${BASH_SOURCE[0]}" != "${0}" ]]; }
die() {
  echo "❌ $*" >&2
  if _is_sourced; then return 1; else exit 1; fi
}

ROOT_TENANT="lib/features/tenant"
SPACING_FILE="lib/core/theme/app_spacing.dart"
REPORT_DIR="scripts/_reports"
TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="scripts/_backups/tenant_fix_${TS}"

mkdir -p "$REPORT_DIR" "$BACKUP_DIR"

echo "== RentEase Tenant True Hardcode Fix =="
echo "Tenant root:   $ROOT_TENANT"
echo "Spacing file:  $SPACING_FILE"
echo "Backup dir:    $BACKUP_DIR"
echo

# --- Sanity checks ---
[ -d "$ROOT_TENANT" ] || die "Missing folder: $ROOT_TENANT (run from project root)"
[ -f "$SPACING_FILE" ] || die "Missing file: $SPACING_FILE"

# --- Backups ---
echo "Backing up app_spacing.dart..."
cp -a "$SPACING_FILE" "$BACKUP_DIR/app_spacing.dart"

echo "Backing up tenant files that contain vertical: 7 or 9 in EdgeInsets.symmetric..."
export BACKUP_DIR ROOT_TENANT
python3 - <<'PY'
import os, re, glob, shutil
backup_dir = os.environ["BACKUP_DIR"]
tenant_root = os.environ["ROOT_TENANT"]

pattern = re.compile(r'EdgeInsets\.symmetric\([^)]*vertical:\s*(7|9)\b')
hits = []
for path in glob.glob(os.path.join(tenant_root, "**", "*.dart"), recursive=True):
    with open(path, "r", encoding="utf-8") as f:
        s = f.read()
    if pattern.search(s):
        hits.append(path)

for p in hits:
    dst = os.path.join(backup_dir, "tenant", p)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(p, dst)

print(f"Backed up {len(hits)} file(s).")
PY
echo "✅ Backups done."
echo

# --- Step 1: Add AppSpacing.s7 and AppSpacing.s9 if missing ---
echo "Ensuring AppSpacing.s7 and AppSpacing.s9 exist..."
python3 - <<'PY'
import re

path = "lib/core/theme/app_spacing.dart"
with open(path, "r", encoding="utf-8") as f:
    s = f.read()

has_s7 = re.search(r'\bstatic const double s7\b', s) is not None
has_s9 = re.search(r'\bstatic const double s9\b', s) is not None
if has_s7 and has_s9:
    print("Already present ✅")
    raise SystemExit(0)

lines = s.splitlines()
insert_idx = None
for i, line in enumerate(lines):
    if re.search(r'\bstatic const double s6\b', line):
        insert_idx = i + 1
        break
if insert_idx is None:
    # insert before final }
    for i in range(len(lines)-1, -1, -1):
        if lines[i].strip() == "}":
            insert_idx = i
            break
    if insert_idx is None:
        insert_idx = len(lines)

inserts = []
if not has_s7:
    inserts.append("  static const double s7 = 7;")
if not has_s9:
    inserts.append("  static const double s9 = 9;")

new_lines = lines[:insert_idx] + inserts + lines[insert_idx:]
out = "\n".join(new_lines)
if s.endswith("\n"):
    out += "\n"

with open(path, "w", encoding="utf-8") as f:
    f.write(out)

print("Inserted:", ", ".join(x.strip() for x in inserts))
PY
echo "✅ Spacing tokens ensured."
echo

# --- Step 2: Replace vertical: 7 and vertical: 9 in tenant files ---
echo "Replacing vertical: 7/9 -> AppSpacing.s7/s9..."
python3 - <<'PY'
import os, re, glob

tenant_root = "lib/features/tenant"

rx7 = re.compile(r'(EdgeInsets\.symmetric\([^)]*vertical:\s*)7(\b)')
rx9 = re.compile(r'(EdgeInsets\.symmetric\([^)]*vertical:\s*)9(\b)')

changed_files = []

for path in glob.glob(os.path.join(tenant_root, "**", "*.dart"), recursive=True):
    with open(path, "r", encoding="utf-8") as f:
        s = f.read()

    # only change raw 7/9 (not already AppSpacing.s7/s9)
    s2 = s
    s2 = re.sub(r'(EdgeInsets\.symmetric\([^)]*vertical:\s*)7(\b)', r'\1AppSpacing.s7\2', s2)
    s2 = re.sub(r'(EdgeInsets\.symmetric\([^)]*vertical:\s*)9(\b)', r'\1AppSpacing.s9\2', s2)

    if s2 != s:
        with open(path, "w", encoding="utf-8") as f:
            f.write(s2)
        changed_files.append(path)

print(f"Updated {len(changed_files)} file(s).")
for p in changed_files:
    print(" -", p)
PY
echo "✅ Replacement done."
echo

# --- Step 3: Re-scan true hardcodes ---
echo "Re-scanning tenant for TRUE hardcodes..."
rg -n --glob "*.dart" -P \
  'Color\(0x[0-9A-Fa-f]{8}\)|\bColors\.(black|white|grey|gray|blue|red|green|amber|orange|purple|brown|teal|cyan|pink|indigo)\b|BorderRadius\.circular\(\s*\d+\s*\)|SizedBox\(\s*(height|width):\s*\d+|fontSize:\s*\d+|BoxShadow\(|EdgeInsets\.(all|only|symmetric)\((?:(?!AppSpacing)[^)]*)\b\d+\b' \
  "$ROOT_TENANT" \
  > "$REPORT_DIR/tenant_true_hardcodes.txt" || true

echo "Saved: $REPORT_DIR/tenant_true_hardcodes.txt"
wc -l "$REPORT_DIR/tenant_true_hardcodes.txt" || true
echo
echo "Top of report:"
sed -n '1,80p' "$REPORT_DIR/tenant_true_hardcodes.txt" || true

echo
echo "✅ Done. Backup is in: $BACKUP_DIR"
