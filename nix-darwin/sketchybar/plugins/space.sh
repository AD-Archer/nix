#!/bin/sh

if [ "$SELECTED" = "true" ] || [ "$SELECTED" = "on" ]; then
  sketchybar --animate sin 12 --set "$NAME" \
    background.color=0xff7dc4e4 \
    icon.color=0xff101418
else
  sketchybar --animate sin 12 --set "$NAME" \
    background.color=0xaa1b252f \
    icon.color=0xffe6edf3
fi
