#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT_DIR/bin/opencode-tunnel"
TMP_HOME="$(mktemp -d)"
trap 'rm -rf "$TMP_HOME"' EXIT

OUTPUT=$(printf 'secret123\nsecret123\n' | HOME="$TMP_HOME" "$CLI" update-password 2>&1)

PASS_FILE="$TMP_HOME/.opencode-tunnel/.password"
[ -f "$PASS_FILE" ] || {
  echo "Expected update-password to create the saved password file"
  exit 1
}

[ "$(cat "$PASS_FILE")" = "secret123" ] || {
  echo "Saved password did not match the entered password"
  exit 1
}

[ "$(stat -f '%Lp' "$PASS_FILE")" = "600" ] || {
  echo "Saved password file permissions were not 600"
  exit 1
}

python3 - <<'PY' "$OUTPUT"
import sys
assert 'Password updated' in sys.argv[1]
PY
if [ $? -ne 0 ]; then
  echo "Expected success output from update-password command"
  exit 1
fi

echo "Update-password contract satisfied"
