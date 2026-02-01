#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/auth_screens_bundle.txt"

FILES=(
  "lib/features/auth/ui/login/login_screen.dart"
  "lib/features/auth/ui/verify_email/verify_email_screen.dart"
  "lib/features/auth/ui/forgot_password/reset_verify_code_screen.dart"
  "lib/features/auth/ui/forgot_password/reset_new_password_screen.dart"
)

{
  echo "============================================================"
  echo "RentEase Frontend - Auth screens bundle"
  echo "Generated: $(date)"
  echo "Project: $ROOT"
  echo "============================================================"
  echo

  for f in "${FILES[@]}"; do
    echo "==================== FILE: $f ===================="
    if [[ -f "$ROOT/$f" ]]; then
      cat "$ROOT/$f"
    else
      echo "MISSING FILE: $f"
    fi
    echo
    echo
  done
} > "$OUT"

echo "✅ Bundle written to: $OUT"
