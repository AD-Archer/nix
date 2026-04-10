#!/bin/sh

if [ "$SELECTED" = "true" ] || [ "$SELECTED" = "on" ]; then
  sketchybar --animate sin 12 --set "$NAME" \
    background.drawing=on \
    background.border_color=0xffffffff \
    icon.color=0xfffc5d7c
else
  sketchybar --animate sin 12 --set "$NAME" \
    background.drawing=off \
    background.border_color=0xe0313436 \
    icon.color=0xffffffff
fi
