#!/bin/sh

PERCENTAGE="$(/usr/bin/pmset -g batt | /usr/bin/grep -Eo '\d+%' | /usr/bin/cut -d% -f1)"
CHARGING="$(/usr/bin/pmset -g batt | /usr/bin/grep 'AC Power')"

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

case "$PERCENTAGE" in
  9[0-9]|100) ICON="" ;;
  [6-8][0-9]) ICON="" ;;
  [3-5][0-9]) ICON="" ;;
  [1-2][0-9]) ICON="" ;;
  *) ICON="" ;;
esac

if [ -n "$CHARGING" ]; then
  ICON=""
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%"
