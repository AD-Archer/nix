#!/bin/sh

if [ -n "$INFO" ]; then
  APP_NAME="$INFO"
else
  APP_NAME="$(yabai -m query --windows --window 2>/dev/null | jq -r '.app // "Desktop"')"
fi

sketchybar --set "$NAME" label="$APP_NAME"
