#!/usr/bin/env bash
set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
info() { echo -e "  ${CYAN}→${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
TARGET="$INSTALL_DIR/opencode-tunnel"

echo ""
echo -e "${BOLD}Installing opencode-tunnel...${NC}"
echo ""

# Create install dir
mkdir -p "$INSTALL_DIR"
ok "Install dir ready: $INSTALL_DIR"

# Copy script
cp "$SCRIPT_DIR/bin/opencode-tunnel" "$TARGET"
chmod +x "$TARGET"
ok "Script installed: $TARGET"

# Add to PATH in .zshrc if not already there
SHELL_RC="$HOME/.zshrc"
if ! grep -q 'HOME/.local/bin' "$SHELL_RC" 2>/dev/null || grep -q '# export PATH=$HOME/bin:$HOME/.local/bin' "$SHELL_RC" 2>/dev/null; then
  if ! grep -qE '^export PATH=.*\.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# opencode-tunnel' >> "$SHELL_RC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    ok "Added ~/.local/bin to PATH in $SHELL_RC"
  fi
fi

echo ""
echo -e "  ${BOLD}Done!${NC} Reload your shell to start using it:"
echo ""
echo -e "    ${CYAN}source ~/.zshrc${NC}"
echo ""
echo -e "  Then run:"
echo ""
echo -e "    ${CYAN}opencode-tunnel help${NC}"
echo ""
