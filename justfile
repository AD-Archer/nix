set shell := ["bash", "-euo", "pipefail", "-c"]

default:
    @just --list

# Install Nix and enable flakes on macOS.
bootstrap:
    ./nix-darwin/scripts/install-nix-flakes-macos.sh

# Apply nix-darwin config to this Mac.
switch verbose="":
    ./nix-darwin/scripts/rebuild.sh switch {{verbose}}

# Build without switching.
build verbose="":
    ./nix-darwin/scripts/rebuild.sh build {{verbose}}

# Evaluate configuration checks only.
check verbose="":
    ./nix-darwin/scripts/rebuild.sh check {{verbose}}

# Generic darwin action wrapper: `just darwin action=switch verbose=--verbose`
darwin action="switch" verbose="":
    sudo ./nix-darwin/scripts/rebuild.sh {{action}} {{verbose}}

# Update flake locks at repo root.
update:
    nix flake update

# --- Linux/NixOS devices ---

# Generic nixos-rebuild wrapper:
# `just nixos action=switch host=hypr`
nixos host action="switch":
    sudo nixos-rebuild {{action}} --flake .#{{host}}

# Explicit host shortcuts.
switch-hypr:
    sudo nixos-rebuild switch --flake .#hypr

build-hypr:
    sudo nixos-rebuild build --flake .#hypr

test-hypr:
    sudo nixos-rebuild test --flake .#hypr

switch-htpc:
    sudo nixos-rebuild switch --flake .#htpc

build-htpc:
    sudo nixos-rebuild build --flake .#htpc

test-htpc:
    sudo nixos-rebuild test --flake .#htpc

# Update per-subflake locks when working inside those device configs.
update-hypr:
    nix flake update --flake ./hypr

update-htpc:
    nix flake update --flake ./htpc
