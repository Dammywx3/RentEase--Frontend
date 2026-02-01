#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/snips_saved_hearts.sh
# Or custom window:
#   bash scripts/snips_saved_hearts.sh 40
#
# This prints code excerpts around known "heart" line numbers so you can paste them.

WIN="${1:-50}" # lines before/after
ROOT="${2:-lib}"

snip () {
  local file="$1"
  local line="$2"
  local start=$(( line - WIN ))
  local end=$(( line + WIN ))
  if (( start < 1 )); then start=1; fi

  echo
  echo "================================================================================"
  echo "FILE: $file"
  echo "AROUND LINE: $line  (window: +/- $WIN)"
  echo "COPY/PASTE THIS WHOLE BLOCK INTO CHAT"
  echo "--------------------------------------------------------------------------------"
  sed -n "${start},${end}p" "$file" | nl -ba
  echo "================================================================================"
}

# Tenant heart locations you listed
snip "$ROOT/features/tenant/explore/explore_screen.dart" 963
snip "$ROOT/features/tenant/search/search_screen.dart" 353
snip "$ROOT/features/tenant/search/search_results_screen.dart" 832
snip "$ROOT/features/tenant/listing_detail/listing_detail_screen.dart" 391

echo
echo "DONE. Paste the 4 blocks above here."
