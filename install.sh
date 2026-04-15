#!/usr/bin/env bash
set -euo pipefail

# ─── Colors ──────────────────────────────────────────────────────
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ok() { echo -e "  ${GREEN}✓${NC} $1"; }
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

# Detect shell RC file — prefer the running shell, fall back by existence.
# On macOS, bash login shells read ~/.bash_profile instead of ~/.bashrc,
# so prefer ~/.bash_profile when it exists or when we're on macOS.
detect_shell_rc() {
	local shell_name os_name
	shell_name="$(basename "${SHELL:-}")"
	os_name="$(uname -s)"
	case "$shell_name" in
	zsh)
		echo "$HOME/.zshrc"
		;;
	bash)
		if [ -f "$HOME/.bash_profile" ]; then
			echo "$HOME/.bash_profile"
		elif [ -f "$HOME/.bashrc" ]; then
			echo "$HOME/.bashrc"
		elif [ "$os_name" = "Darwin" ]; then
			echo "$HOME/.bash_profile"
		else
			echo "$HOME/.bashrc"
		fi
		;;
	*)
		# Fall back to whichever exists, preferring login-shell files on macOS
		if [ -f "$HOME/.zshrc" ]; then
			echo "$HOME/.zshrc"
		elif [ -f "$HOME/.bash_profile" ]; then
			echo "$HOME/.bash_profile"
		elif [ -f "$HOME/.bashrc" ]; then
			echo "$HOME/.bashrc"
		elif [ "$os_name" = "Darwin" ]; then
			echo "$HOME/.bash_profile"
		else
			echo "$HOME/.bashrc"
		fi
		;;
	esac
}

SHELL_RC="$(detect_shell_rc)"

if ! grep -qE '^export PATH=.*\.local/bin' "$SHELL_RC" 2>/dev/null; then
	echo '' >>"$SHELL_RC"
	echo '# opencode-tunnel' >>"$SHELL_RC"
	echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$SHELL_RC"
	ok "Added ~/.local/bin to PATH in $SHELL_RC"
fi

echo ""
echo -e "  ${BOLD}Done!${NC} Reload your shell to start using it:"
echo ""
echo -e "    ${CYAN}source \"${SHELL_RC}\"${NC}"
echo ""
echo -e "  Then run:"
echo ""
echo -e "    ${CYAN}opencode-tunnel help${NC}"
echo ""
