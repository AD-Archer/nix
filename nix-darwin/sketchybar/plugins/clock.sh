#!/bin/sh

sketchybar --set "$NAME" icon="$(/bin/date '+%a %d %b')" label="$(/bin/date '+%H:%M')"
