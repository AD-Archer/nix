#!/bin/sh

# The front_app_switched event supplies $INFO with the name of the new app
if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO"
else
  # Fallback: get current app name using yabai query
  APP_NAME=$(yabai -m query --windows --window | jq -r '.app')
  sketchybar --set "$NAME" label="${APP_NAME:-"Desktop"}"
fi
