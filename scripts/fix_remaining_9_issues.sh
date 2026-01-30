#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "📍 Repo: $ROOT_DIR"

TS="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR=".bak_fix_remaining_9_$TS"
mkdir -p "$BACKUP_DIR"

backup() {
  local f="$1"
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
}

FILES=(
  "lib/features/agent/listings/create_listing/create_listing_stepper.dart"
  "lib/features/agent/tenancies/tenancy_detail_screen.dart"
  "lib/features/auth/ui/register/register_state.dart"
  "lib/features/tenant/maintenance/create_request_screen.dart"
  "lib/features/tenant/profile/documents/upload_document_screen.dart"
)

echo "🗂️ Backing up touched files..."
for f in "${FILES[@]}"; do
  backup "$f"
done

echo "🛠️ Applying fixes..."
python3 - <<'PY'
from pathlib import Path
import re

def r(p: Path) -> str:
    return p.read_text(encoding="utf-8")

def w(p: Path, s: str) -> None:
    p.write_text(s, encoding="utf-8")

def fix_if_needs_braces(p: Path) -> bool:
    """
    Fix both styles:
      A) if (cond) stmt;
      B) if (cond)
            stmt;
    into:
      if (cond) { stmt; }
    Conservative: only wraps a single statement ending with ';' (not blocks).
    """
    if not p.exists():
        return False
    s0 = r(p)
    lines = s0.splitlines(True)

    changed = False
    i = 0
    while i < len(lines):
        line = lines[i]
        if_m = re.match(r'^(\s*)if\s*\((.*)\)\s*(.*)$', line)
        if not if_m:
            i += 1
            continue

        indent = if_m.group(1)
        rest_after = if_m.group(3).rstrip("\n")

        # Skip if already has '{' on same line
        if "{" in rest_after:
            i += 1
            continue

        # Case A: same-line statement
        # Example: if (x) doThing();
        # Allow trailing comments after ';'
        if re.search(r';\s*(//.*)?$', rest_after) and rest_after.strip() != "":
            stmt = rest_after.strip()
            # If this is like "if (x) else ..." ignore
            if stmt.startswith("else"):
                i += 1
                continue
            # Rewrite line to include braces
            # Keep any trailing comment
            m = re.match(r'^(.*?;)(\s*//.*)?$', stmt)
            if m:
                stmt_only = m.group(1)
                comment = m.group(2) or ""
                lines[i] = f"{indent}if ({if_m.group(2)}) {{ {stmt_only} }}{comment}\n"
                changed = True
            i += 1
            continue

        # Case B: statement on next non-empty line
        j = i + 1
        while j < len(lines) and lines[j].strip() == "":
            j += 1
        if j >= len(lines):
            break

        next_line = lines[j]
        # Skip if next line already a block
        if next_line.lstrip().startswith("{"):
            i += 1
            continue
        # Only wrap if the next non-empty line ends with ';'
        if not re.search(r';\s*(//.*)?\s*$', next_line):
            i += 1
            continue

        # Rewrite:
        # line i becomes: if (cond) {
        # line j stays but indented one level (best-effort)
        # insert closing brace after line j
        cond = if_m.group(2)
        lines[i] = f"{indent}if ({cond}) {{\n"

        # Indent statement line one extra level (2 spaces)
        stmt_indent = indent + "  "
        # Preserve original statement content stripped of leading indentation
        stmt_body = next_line.lstrip()
        lines[j] = f"{stmt_indent}{stmt_body}"
        # Insert closing brace after j
        lines.insert(j + 1, f"{indent}}}\n")
        changed = True
        # Move i past the inserted brace
        i = j + 2
        continue

    if changed:
        w(p, "".join(lines))
    return changed

# Fix curly brace infos
fix_if_needs_braces(Path("lib/features/agent/listings/create_listing/create_listing_stepper.dart"))
fix_if_needs_braces(Path("lib/features/agent/tenancies/tenancy_detail_screen.dart"))

# Fix register_state.dart:
# - Remove any @override that sits above a getter (those are causing "doesn't override")
# - Add @override above the member named "user" (getter or field) if missing
rs = Path("lib/features/auth/ui/register/register_state.dart")
if rs.exists():
    s0 = r(rs)
    lines = s0.splitlines(True)

    # 1) Remove @override directly above ANY getter line: "get something"
    out = []
    i = 0
    while i < len(lines):
        if lines[i].strip() == "@override":
            j = i + 1
            while j < len(lines) and lines[j].strip() == "":
                j += 1
            if j < len(lines) and re.search(r'\bget\s+\w+\b', lines[j]):
                # drop this @override (getter override warning)
                i += 1
                continue
        out.append(lines[i])
        i += 1
    s1 = "".join(out)

    # 2) Ensure @override exists above the first "user" member (getter or field)
    # Matches:
    #   ... get user
    #   final X user;
    #   X user;
    #   late X user;
    #   X? user;
    patt_user_member = re.compile(
        r'^\s*(?:late\s+|final\s+)?[A-Za-z_]\w*(?:<[^;>]*>)?(?:\?)?\s+user\b|^\s*\w.*\bget\s+user\b',
        re.M
    )

    lines = s1.splitlines(True)
    out = []
    inserted = False
    for idx, line in enumerate(lines):
        if (not inserted) and patt_user_member.search(line):
            # check prev non-empty in out
            k = len(out) - 1
            while k >= 0 and out[k].strip() == "":
                k -= 1
            prev = out[k].strip() if k >= 0 else ""
            if prev != "@override":
                indent = re.match(r'^(\s*)', line).group(1)
                out.append(f"{indent}@override\n")
            inserted = True
        out.append(line)

    s2 = "".join(out)
    if s2 != s0:
        w(rs, s2)

# Fix "value is deprecated" ONLY inside TextFormField / DropdownButtonFormField blocks
def replace_value_with_initialvalue_in_form_fields(p: Path) -> None:
    if not p.exists():
        return
    s0 = r(p)
    lines = s0.splitlines(True)

    targets = ("TextFormField(", "DropdownButtonFormField(", "DropdownButtonFormField<")
    out = []
    in_target = False
    paren_depth = 0

    for line in lines:
        if any(t in line for t in targets):
            in_target = True
            # crude depth count
            paren_depth += line.count("(") - line.count(")")
        elif in_target:
            paren_depth += line.count("(") - line.count(")")
            if paren_depth <= 0:
                in_target = False
                paren_depth = 0

        if in_target:
            # Only replace the parameter label at start-of-arg (best effort)
            # "value: xxx" -> "initialValue: xxx"
            line = re.sub(r'(^\s*)value\s*:', r'\1initialValue:', line)
        out.append(line)

    s1 = "".join(out)
    if s1 != s0:
        w(p, s1)

replace_value_with_initialvalue_in_form_fields(Path("lib/features/tenant/maintenance/create_request_screen.dart"))
replace_value_with_initialvalue_in_form_fields(Path("lib/features/tenant/profile/documents/upload_document_screen.dart"))

print("✅ Applied targeted code edits.")
PY

echo "🎨 dart format..."
dart format lib test >/dev/null || true

echo "🔎 flutter analyze..."
flutter analyze || true

echo
echo "✅ Done."
echo "🗂️ Backups saved in: $BACKUP_DIR"
