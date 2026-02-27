#!/bin/sh
STATE="${XDG_RUNTIME_DIR:-/tmp}/wezterm-opacity-toggle"
if grep -sq opaque "$STATE" 2>/dev/null; then
    printf '' > "$STATE"
else
    printf 'opaque' > "$STATE"
fi
