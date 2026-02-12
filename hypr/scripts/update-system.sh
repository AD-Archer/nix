#!/usr/bin/env bash
# Update NixOS system packages and flake inputs

set -euo pipefail

NIXOS_DIR="/etc/nixos"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

cd "$NIXOS_DIR"

echo ""
echo "╔════════════════════════════════════════╗"
echo "║       NixOS System Update Script       ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Check for uncommitted changes
if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    print_warning "You have uncommitted changes in $NIXOS_DIR"
    echo "    Consider committing them first with: git add -A && git commit -m 'your message'"
    echo ""
fi

# Update flake inputs
print_step "Updating flake inputs (nixpkgs, home-manager, etc.)..."
nix flake update
print_success "Flake inputs updated"

# Show what changed in the lock file
echo ""
print_step "Changes to flake.lock:"
git diff flake.lock 2>/dev/null | head -30 || echo "  (no changes or not a git repo)"
echo ""

# Build the new configuration
print_step "Building new system configuration..."
if sudo nixos-rebuild switch --flake "$NIXOS_DIR"; then
    print_success "System rebuilt successfully!"
else
    echo -e "${RED}✗${NC} Build failed. Check the errors above."
    exit 1
fi

# Optional: Update user profile packages
print_step "Updating user environment..."
nix-env --upgrade 2>/dev/null || true

# Garbage collection prompt
echo ""
read -p "Run garbage collection to free disk space? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Running garbage collection..."
    sudo nix-collect-garbage -d
    nix-collect-garbage -d
    print_success "Garbage collection complete"
fi

echo ""
echo "╔════════════════════════════════════════╗"
echo "║          Update Complete! 🎉           ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Tips:"
echo "  • Check for issues: journalctl -b --priority=err"
echo "  • Rollback if needed: sudo nixos-rebuild switch --rollback"
echo "  • List generations: sudo nix-env --list-generations -p /nix/var/nix/profiles/system"
