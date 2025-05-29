#!/bin/sh

# Adapted from https://github.com/hyprwm/Hyprland/discussions/8668

# Get active workspace id
id=$(hyprctl -j activeworkspace | jq ".id")

# Set range variable in order to match the workspace in hyprctl commands
rid="r[$id-$id]"

# Detect whether there is a workspace rule for the active workspace
rule_exists=$(hyprctl workspacerules -j | jq "any(.[]; .workspaceString==\"$rid\")")

# If a rule exists, figure out the rules for inner and outer gaps, if any
#
# Inferring "1" if there's no rule, as then we're on defaults and should toggle to 0
if $rule_exists; then
  gaps_in_current=$(
    hyprctl workspacerules -j | jq 'first(.[] | select(.workspaceString == "'"$rid"'")) | .gapsIn[0] // 1'
  )
  gaps_out_current=$(
    hyprctl workspacerules -j | jq 'first(.[] | select(.workspaceString == "'"$rid"'")) | .gapsOut[0] // 1'
  )
else
  gaps_in_current=1
  gaps_out_current=1
fi

# Function to extract the first number from a string like "100 5 43 2", where
# the quotes are included in the string
extract_first_number() {
  str=$1         # Input string
  str=${str#\"}  # Remove leading quote
  str=${str%% *} # Extract first number from space-separated string
  echo $str      # Output the first number
}

# Toggle to 0 gaps if either is nonzero, otherwise toggle to defaults
if [ "$gaps_in_current" -ne 0 ] || [ "$gaps_out_current" -ne 0 ]; then
  hyprctl keyword workspace "$rid,gapsin:0,gapsout:0,bordersize:1,rounding:false" -r > /dev/null
  hyprctl keyword windowrule "bordersize 1, rounding 0, onworkspace:$rid" -r > /dev/null
else
  # Retrieve defaults
  gaps_in_default=$(hyprctl getoption general:gaps_in -j | jq '.custom')
  gaps_in_default=$(extract_first_number "$gaps_in_default")
  gaps_out_default=$(hyprctl getoption general:gaps_out -j | jq '.custom')
  gaps_out_default=$(extract_first_number "$gaps_out_default")
  border_size_default=$(hyprctl getoption general:border_size -j | jq '.int')
  hyprctl keyword workspace "$rid,gapsin:$gaps_in_default,gapsout:$gaps_out_default,bordersize:$border_size_default,rounding:true" -r > /dev/null
  hyprctl keyword windowrule "bordersize $border_size_default, rounding 1, onworkspace:$rid" -r > /dev/null
fi

# To force a redraw of the window corners, we will make the active window float then unfloat
hyprctl dispatch togglefloating > /dev/null
hyprctl dispatch togglefloating > /dev/null
