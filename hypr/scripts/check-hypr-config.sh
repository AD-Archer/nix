#!/usr/bin/env bash
set -euo pipefail

default_repo_config="/etc/nixos/modules/hyprland/configs/xdg/hypr/hyprland.conf"
default_live_config="$HOME/.config/hypr/hyprland.conf"

case "${1:-}" in
  --repo)
    config_path="$default_repo_config"
    ;;
  --live|"")
    config_path="$default_live_config"
    ;;
  *)
    config_path="$1"
    ;;
esac

if ! command -v Hyprland >/dev/null 2>&1; then
  echo "error: Hyprland not found in PATH" >&2
  exit 127
fi

if [[ ! -f "$config_path" ]]; then
  echo "error: config not found: $config_path" >&2
  exit 2
fi

Hyprland --verify-config --config "$config_path"
