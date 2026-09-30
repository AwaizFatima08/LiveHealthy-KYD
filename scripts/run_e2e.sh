#!/usr/bin/env bash
# End-to-end test on a device/emulator. Content comes from a LOCAL Firestore
# emulator, never production.
# Prereqs: a device attached (adb devices), and in another terminal
#   firebase emulators:start --only firestore      (repo root, JDK 21+)
# Usage: scripts/run_e2e.sh [device-id]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE="${1:-emulator-5554}"
# Start from an empty emulator (the local emulator's REST endpoint only),
# then seed it with the current content.
curl -sf -X DELETE "http://127.0.0.1:8086/emulator/v1/projects/livehealthy-kyd/databases/(default)/documents" >/dev/null
FIRESTORE_EMULATOR_HOST=127.0.0.1:8086 "$ROOT/scripts/.venv/bin/python" "$ROOT/scripts/publish_content.py" --publish
if [[ "$DEVICE" == emulator-* ]]; then
  HOST=10.0.2.2
else
  # Not 127.0.0.1/localhost: FlutterFire rewrites those to 10.0.2.2 on
  # Android. 127.0.0.2 is still loopback and reaches the adb reverse tunnel.
  HOST=127.0.0.2
  adb -s "$DEVICE" reverse tcp:8086 tcp:8086
  export E2E_SHOTS_DIR="${E2E_SHOTS_DIR:-../store/graphics/device_run_$DEVICE}"
fi
cd "$ROOT/app"
flutter drive -d "$DEVICE" \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_flow_test.dart \
  --dart-define=FIRESTORE_EMULATOR_HOST=$HOST
