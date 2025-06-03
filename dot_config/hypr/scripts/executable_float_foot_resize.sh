#!/bin/sh

# Get the class of the currently focused window
class=$(hyprctl activewindow -j | jq -r '.class')

# Toggle floating
hyprctl dispatch togglefloating

# Only apply resize if the class is foot and it's now floating
if [ "$class" = "foot" ]; then
    sleep 0.05  # short delay to allow floating toggle to apply
    is_floating=$(hyprctl activewindow -j | jq -r '.floating')

    if [ "$is_floating" = "true" ]; then
        hyprctl dispatch resizeactive exact 800 1000
    fi
fi

