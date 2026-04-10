#!/bin/sh

# The volume_change event supplies $INFO variable with the new volume
if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"
else
  VOLUME="$(/usr/bin/osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi

case "$VOLUME" in
  [6-9][0-9]|100) ICON="" ;;
  [3-5][0-9]) ICON="" ;;
  [1-9]|[1-2][0-9]) ICON="" ;;
  *) ICON="" ;;
esac

LABEL="${VOLUME:-0}%"

if [ "$NAME" = "volume_icon" ]; then
  sketchybar --set "$NAME" icon="$ICON"
else
  sketchybar --set "$NAME" label="$LABEL"
fi

if [ "$SENDER" = "mouse.clicked" ]; then
  /usr/bin/open /System/Library/PreferencePanes/Sound.prefPane >/dev/null 2>&1
fi

if [ "$SENDER" = "mouse.scrolled" ]; then
  DELTA=$(printf '%s' "$INFO" | /usr/bin/sed -nE 's/.*delta:([+-]?[0-9.]+).*/\1/p')
  if [ -n "$DELTA" ]; then
    /usr/bin/osascript -e "set volume output volume (output volume of (get volume settings) + ($DELTA * 10))" >/dev/null 2>&1
  fi
fi
