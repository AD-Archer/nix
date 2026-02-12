#!/usr/bin/env bash
# Update QuickShell config from the dots-hyprland source repo

set -euo pipefail

NIXOS_DIR="/etc/nixos"
SOURCE_DIR="$NIXOS_DIR/sources/dots-hyprland"
CONFIG_DIR="$NIXOS_DIR/modules/quickshell/config/ii"

echo "=== Updating QuickShell Config ==="

# Check if source directory exists
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "Error: Source directory not found at $SOURCE_DIR"
    echo "Clone it first with: git clone <repo-url> $SOURCE_DIR"
    exit 1
fi

# Update the source repo
echo "📥 Pulling latest changes from dots-hyprland..."
cd "$SOURCE_DIR"
git pull --rebase || echo "Warning: Could not pull (might be offline or have local changes)"

# Update submodules (like the shapes module)
echo "📦 Updating submodules..."
git submodule update --init --recursive

# Copy updated config files
echo "📋 Copying config files to NixOS module..."
cp -r dots/.config/quickshell/ii/* "$CONFIG_DIR/"

# Remove .git submodule markers so Nix includes the files
echo "🧹 Cleaning up git markers..."
find "$CONFIG_DIR" -name ".git" -type f -delete 2>/dev/null || true

# Stage changes in git
echo "📝 Staging changes..."
cd "$NIXOS_DIR"
git add modules/quickshell/config/

echo ""
echo "✅ QuickShell config updated!"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff --cached"
echo "  2. Rebuild: sudo nixos-rebuild switch --flake /etc/nixos"
echo "  3. Restart quickshell or log out/in"
