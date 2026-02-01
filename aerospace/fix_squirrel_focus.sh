#!/bin/bash
sleep 0.03
FOCUS_APP=$(aerospace list-windows --focused --format '%{app-bundle-id}' 2>/dev/null)
if [ "$FOCUS_APP" = "im.rime.inputmethod.Squirrel" ]; then
    aerospace focus-back-and-forth
fi
