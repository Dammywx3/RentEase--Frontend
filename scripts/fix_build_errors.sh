#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

say() { printf "\n\033[1;36m%s\033[0m\n" "$*"; }
die() { printf "\n\033[1;31mERROR:\033[0m %s\n" "$*" >&2; exit 1; }

need_file() {
  [[ -f "$1" ]] || die "Missing file: $1"
}

apply() {
  local file="$1"
  local desc="$2"
  local cmd="$3"

  need_file "$file"
  say "PATCH: $desc"
  bash -c "$cmd"
}

say "Project: $ROOT"
say "1) Fix wrong imports for schedule_visit_screen.dart in listing_detail_screen.dart (pubspec name is rentease_frontend)"

LISTING_DETAIL="lib/features/tenant/listing_detail/listing_detail_screen.dart"
if [[ -f "$LISTING_DETAIL" ]]; then
  # Replace wrong package import (rentease_app) with correct relative path
  if rg -n "package:rentease_app/features/viewings/ui/schedule_visit_screen\.dart" "$LISTING_DETAIL" >/dev/null 2>&1; then
    apply "$LISTING_DETAIL" "Fix schedule_visit_screen import path" \
      "perl -0777 -i -pe 's@import\\s+\\x27package:rentease_app/features/viewings/ui/schedule_visit_screen\\.dart\\x27;@import \\'schedule_visit_screen.dart\\';@g' '$LISTING_DETAIL'"
  fi
else
  say "SKIP: $LISTING_DETAIL not found (ok if you moved it)"
fi

say "2) Fix AppTopBar unsupported params (centerTitle, leadingIcon, onLeadingTap)"

TOPBAR="lib/core/ui/scaffold/app_top_bar.dart"
need_file "$TOPBAR"

# In files that pass centerTitle: true => remove it (AppTopBar already centerTitle:true internally)
for f in \
  "lib/features/tenant/renting_tools/renting_tools_screen.dart" \
  "lib/features/tenant/tenancy/tenancies_screen.dart"
do
  if [[ -f "$f" ]]; then
    if rg -n "centerTitle\\s*:" "$f" >/dev/null 2>&1; then
      apply "$f" "Remove centerTitle param from AppTopBar usages in $(basename "$f")" \
        "perl -0777 -i -pe 's/,\\s*centerTitle\\s*:\\s*true\\s*//g; s/centerTitle\\s*:\\s*true\\s*,\\s*//g' '$f'"
    fi
  fi
done

# In schedule_visit_screen.dart and apply_flow_screens.dart: replace leadingIcon/onLeadingTap with leading widget
SCHEDULE="lib/features/tenant/listing_detail/schedule_visit_screen.dart"
APPLYFLOW="lib/features/tenant/applications/apply_flow_screens.dart"

if [[ -f "$SCHEDULE" ]]; then
  # Replace:
  # AppTopBar(title: 'HomeStead', leadingIcon: X, onLeadingTap: () => ...)
  # with:
  # AppTopBar(title: 'HomeStead', leading: IconButton(...))
  apply "$SCHEDULE" "Replace AppTopBar(leadingIcon/onLeadingTap) with leading widget" \
    "perl -0777 -i -pe 's/AppTopBar\\(\\s*([^\\)]*?)title:\\s*([^,\\)]*),\\s*leadingIcon:\\s*([^,\\)]*),\\s*onLeadingTap:\\s*\\(\\)\\s*=>\\s*([^\\)]*?)\\s*,/AppTopBar(\\1title: \\2, leading: IconButton(icon: Icon(\\3), onPressed: () { \\4; }),/sg' '$SCHEDULE' || true"
fi

if [[ -f "$APPLYFLOW" ]]; then
  apply "$APPLYFLOW" "Replace AppTopBar(leadingIcon/onLeadingTap) with leading widget" \
    "perl -0777 -i -pe 's/AppTopBar\\(\\s*([^\\)]*?)title:\\s*([^,\\)]*),\\s*leadingIcon:\\s*([^,\\)]*),\\s*onLeadingTap:\\s*\\(\\)\\s*=>\\s*([^\\)]*?)\\s*,/AppTopBar(\\1title: \\2, leading: IconButton(icon: Icon(\\3), onPressed: () { \\4; }),/sg' '$APPLYFLOW' || true"
fi

say "3) Fix MaterialLocalizations.formatShortWeekday (does not exist) in schedule_visit_screen.dart"

if [[ -f "$SCHEDULE" ]]; then
  # Replace loc.formatShortWeekday(d) with our local helper _shortWeekday(loc, d)
  # We'll insert helper method once per file if missing.
  if rg -n "formatShortWeekday\\(" "$SCHEDULE" >/dev/null 2>&1; then
    apply "$SCHEDULE" "Replace formatShortWeekday calls" \
      "perl -0777 -i -pe 's/loc\\.formatShortWeekday\\(([^\\)]*)\\)/_shortWeekday(loc, \\1)/g' '$SCHEDULE'"
  fi

  if ! rg -n "_shortWeekday\\(" "$SCHEDULE" >/dev/null 2>&1; then
    die "Expected _shortWeekday usage after replacement, but none found."
  fi

  if ! rg -n "String\\s+_shortWeekday\\(" "$SCHEDULE" >/dev/null 2>&1; then
    # Insert helper inside _ScheduleVisitScreenState (best effort: after class state opening brace)
    apply "$SCHEDULE" "Insert _shortWeekday helper into _ScheduleVisitScreenState" \
      "perl -0777 -i -pe 's/class\\s+_ScheduleVisitScreenState\\s+extends\\s+State<ScheduleVisitScreen>\\s*\\{\\s*/\$&\\n  String _shortWeekday(MaterialLocalizations loc, DateTime d) {\\n    // MaterialLocalizations has no formatShortWeekday; use the narrow weekdays.\\n    const w = [\\x27Mon\\x27, \\x27Tue\\x27, \\x27Wed\\x27, \\x27Thu\\x27, \\x27Fri\\x27, \\x27Sat\\x27, \\x27Sun\\x27];\\n    final idx = (d.weekday - 1) % 7;\\n    return w[idx];\\n  }\\n\\n/sg' '$SCHEDULE'"
  fi
fi

say "4) Fix AppRadii.xs usage (token does not exist). Use AppRadii.xxs (your file defines xxs=6) or sm."

if [[ -f "$APPLYFLOW" ]]; then
  if rg -n "AppRadii\\.xs\\b" "$APPLYFLOW" >/dev/null 2>&1; then
    apply "$APPLYFLOW" "Replace AppRadii.xs with AppRadii.xxs" \
      "perl -0777 -i -pe 's/AppRadii\\.xs\\b/AppRadii.xxs/g' '$APPLYFLOW'"
  fi
fi

say "5) Fix const PageController(...) where constructor isn't const (renting_tools_screen.dart)"

RENTING="lib/features/tenant/renting_tools/renting_tools_screen.dart"
if [[ -f "$RENTING" ]]; then
  if rg -n "const PageController\\(" "$RENTING" >/dev/null 2>&1; then
    apply "$RENTING" "Remove const from PageController constructor" \
      "perl -0777 -i -pe 's/final\\s+PageController\\s+_pc\\s*=\\s*const\\s+PageController\\(/final PageController _pc = PageController(/g' '$RENTING'"
  fi
fi

say "✅ Done patching. Now run flutter analyze to see what's left."
say "Next commands:"
echo "flutter analyze"
echo "flutter run"
