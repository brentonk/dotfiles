#!/bin/bash
# Waybar indicator for a dedicated scratchpad app (see sway config $mod+s/$mod+o).
# Usage: scratchpad_indicator.sh <app_id> <icon>
# Emits waybar JSON: icon with class "visible" or "hidden" while the app is
# running, class "empty" with no text when it is not. Event-driven via sway IPC.
# Matches native-Wayland windows by app_id, and Xwayland windows (which have no
# app_id, e.g. Spotify on Arch) by their X11 class, compared case-insensitively
# against the passed app_id ("spotify" matches class "Spotify").

app_id="$1"
icon="$2"

emit() {
    swaymsg -t get_tree | jq -c --arg app_id "$app_id" --arg icon "$icon" '
        [recurse(.nodes[]?, .floating_nodes[]?)
         | select((.app_id? == $app_id)
                  or (((.window_properties.class? // "") | ascii_downcase) == $app_id))] | first as $win |
        if $win == null then {text: "", class: "empty"}
        elif $win.visible then {text: $icon, class: "visible", tooltip: ($win.name // $app_id)}
        else {text: $icon, class: "hidden", tooltip: (($win.name // $app_id) + " (scratchpad)")}
        end'
}

emit
swaymsg -t subscribe -m '["window"]' | while read -r _; do
    emit
done
