#!/bin/sh
# Simple wrapper script for darwin-rebuild using nix run
# Usage: ./rebuild.sh [switch|build|check] [--verbose]

# Default action is switch if none provided
ACTION=${1:-switch}
VERBOSE=""

# Check for verbose flag
if [ "$2" = "--verbose" ] || [ "$2" = "-v" ]; then
  VERBOSE="--verbose"
fi

# Run darwin-rebuild with the specified action
nix run github:LnL7/nix-darwin/master -- $ACTION $VERBOSE --flake "$PWD#mac" 