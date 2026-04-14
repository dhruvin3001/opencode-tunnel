#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

[ -f "$ROOT_DIR/bin/opencode-tunnel" ] || {
  echo "Expected renamed CLI at bin/opencode-tunnel"
  exit 1
}

python3 - <<'PY' "$ROOT_DIR"
from pathlib import Path
import sys

root = Path(sys.argv[1])

assert (root / 'README.md').read_text().splitlines()[0] == '# opencode-tunnel', 'README title was not renamed to opencode-tunnel'
assert 'TARGET="$INSTALL_DIR/opencode-tunnel"' in (root / 'install.sh').read_text(), 'install.sh does not install opencode-tunnel'
assert 'STATE_DIR="$HOME/.opencode-tunnel"' in (root / 'bin' / 'opencode-tunnel').read_text(), 'CLI state directory was not renamed to ~/.opencode-tunnel'

needle = 'opencode-anywhere'
for path in root.rglob('*'):
    if '.git' in path.parts:
        continue
    if path == root / 'tests' / 'rename_contract.sh':
        continue
    if path.is_file() and needle in path.read_text(errors='ignore'):
        raise AssertionError(f'Found old project name still present in repository: {path}')
PY

echo "Rename contract satisfied"
