#!/usr/bin/env bash
set -euo pipefail

echo "== RentEase Frontend: auth/core sanity check =="

flutter --version
echo

echo "== pub get =="
flutter pub get
echo

echo "== format (lib only) =="
dart format lib
echo

echo "== analyze =="
flutter analyze
echo

echo "== done ✅ =="
echo "If login fails on Android emulator, confirm BASE_URL is http://10.0.2.2:4000"
echo "You can set: BASE_URL in .env OR use --dart-define=BASE_URL=http://10.0.2.2:4000"
