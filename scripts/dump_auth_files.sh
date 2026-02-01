#!/usr/bin/env bash
set -euo pipefail

ROOT="$(pwd)"
OUT="auth_dump_$(date +%Y%m%d_%H%M%S).txt"

FILES=(
  "lib/app/router/app_router.dart"
  "lib/app/bootstrap.dart"
  "lib/main.dart"

  "lib/features/auth/data/auth_di.dart"
  "lib/features/auth/data/auth_repo.dart"
  "lib/core/network/api_client.dart"

  "lib/features/auth/ui/login/login_screen.dart"
  "lib/features/auth/ui/forgot_password/forgot_password_screen.dart"
  "lib/features/auth/ui/forgot_password/reset_verify_code_screen.dart"
  "lib/features/auth/ui/forgot_password/reset_new_password_screen.dart"

  "lib/shared/models/user_model.dart"
)

hr() { printf '%*s\n' 120 '' | tr ' ' '='; }

echo "Writing dump to: $OUT"
: > "$OUT"

for f in "${FILES[@]}"; do
  hr | tee -a "$OUT"
  echo "FILE: $f" | tee -a "$OUT"
  hr | tee -a "$OUT"
  if [[ -f "$f" ]]; then
    # line numbers help a lot for debugging
    nl -ba "$f" | tee -a "$OUT"
    echo "" | tee -a "$OUT"
  else
    echo "MISSING: $f (file not found)" | tee -a "$OUT"
    echo "" | tee -a "$OUT"
  fi
done

hr | tee -a "$OUT"
echo "DONE. Paste the contents of: $OUT" | tee -a "$OUT"
hr | tee -a "$OUT"
