#!/usr/bin/env bash
set -euo pipefail

echo "== Fix duplicate FloatingActionButton hero tags =="
FILES=$(rg -l "FloatingActionButton\(" lib || true)

if [[ -z "${FILES}" ]]; then
  echo "No FloatingActionButton found."
  exit 0
fi

while IFS= read -r f; do
  cp -a "$f" "$f.bak.$(date +%Y%m%d_%H%M%S)"

  # Add heroTag if missing inside FloatingActionButton(...)
  # This is conservative: it only patches FAB blocks that don't already mention heroTag:
  perl -0777 -i -pe '
    my $file = $ARGV;
    my $safe = $file; $safe =~ s/[^a-zA-Z0-9]+/_/g;

    s/FloatingActionButton\(\s*(?![^)]*heroTag:)/"FloatingActionButton(\n  heroTag: '\''fab_${safe}_".(++$::i)."'\',\n"/ge;
  ' "$f"

  echo "✓ patched $f"
done <<< "$FILES"

echo ""
echo "Run: flutter run (or flutter analyze) to confirm."
