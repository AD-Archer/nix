#!/usr/bin/env bash
# Locks Hyprland session on lid close.
USER_NAME=arch
USER_UID=$(id -u "$USER_NAME" 2>/dev/null) || exit 0
RUNTIME_DIR="/run/user/${USER_UID}"
[ -d "$RUNTIME_DIR" ] || exit 0

get_wayland_display() {
  local hypr_pid
  hypr_pid=$(pgrep -u "$USER_NAME" -x Hyprland | head -n1)
  if [ -n "$hypr_pid" ] && [ -r "/proc/$hypr_pid/environ" ]; then
    tr '\0' '\n' < "/proc/$hypr_pid/environ" | sed -n 's/^WAYLAND_DISPLAY=//p' | head -n1
  fi
}

WAYLAND_DISPLAY=$(get_wayland_display)
if [ -z "$WAYLAND_DISPLAY" ]; then
  WAYLAND_DISPLAY=$(ls "$RUNTIME_DIR"/wayland-* 2>/dev/null | head -n1 | xargs -r basename)
fi
[ -n "$WAYLAND_DISPLAY" ] || exit 0

export XDG_RUNTIME_DIR="$RUNTIME_DIR"
export WAYLAND_DISPLAY
export PATH="/run/current-system/sw/bin:$PATH"

# Avoid spawning multiple hyprlock instances
pgrep -u "$USER_NAME" -x hyprlock >/dev/null 2>&1 && exit 0

sudo -u "$USER_NAME" env XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" hyprlock
