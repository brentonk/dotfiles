#!/bin/bash
# Waybar counter for generic scratchpad windows, excluding the dedicated
# scratchpad apps (spotify/obsidian), which have their own indicators.
# Usage: scratchpad_count.sh <icon>
# Emits waybar JSON: "<icon> <count>" when count > 0, class "empty" otherwise.

icon="$1"

emit() {
    swaymsg -t get_tree | jq -c --arg icon "$icon" '
        [.. | objects | select(.name? == "__i3_scratch") | .floating_nodes[]?
         | select((.app_id // .window_properties.class // "") as $a
                  | ["spotify", "obsidian"] | index($a) | not)]
        | if length == 0 then {text: "", class: "empty"}
          else {text: "\($icon) \(length)", tooltip: ([.[] | .name // "?"] | join("\n"))}
          end'
}

emit
swaymsg -t subscribe -m '["window"]' | while read -r _; do
    emit
done
