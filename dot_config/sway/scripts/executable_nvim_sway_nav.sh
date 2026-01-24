#!/bin/sh

# Sway navigation script with nvim integration
# Adapted from nvim_hypr_nav.sh for Hyprland

# Usage: nvim_sway_nav.sh [direction]

dir="$1"
timeout="${SWAY_NAV_TIMEOUT:-0.1s}"

# Wrapper to run a command in nvim server, timing out if it takes too long
nvim_remote_expr() {
  timeout "$timeout" nvim --headless --server "$servername" --remote-expr "$@"
}

# Check that the direction is valid, exit with error if not
case "$dir" in
    left|right|up|down) ;;
    *)
        echo "Usage: $0 [left|right|up|down]"
        exit 1
        ;;
esac

# Get the PID of the focused window using swaymsg
focused_pid="$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .pid // empty' 2>/dev/null | head -1)"

# Look for a serverfile for an nvim process in the focused window
# Support both naming conventions for compatibility
servername_file="${XDG_RUNTIME_DIR:-/tmp}/nvim-hypr-nav.${focused_pid}.servername"

# If the serverfile exists, ask the associated nvim server to run the given
# navigation command
if [ -f "$servername_file" ]; then
  # Read the servername from the file
  read -r servername < "$servername_file"

  # If we have a servername, run the corresponding navigation call in nvim and exit
  if [ -n "$servername" ]; then
    nvim_out="$(nvim_remote_expr "v:lua.NvimHyprNav('$dir')")"
    [ "$nvim_out" = "true" ] && exit 0
  fi
fi

# If we didn't find an nvim process, or if the servername was not set, or if
# the nvim command spit back "false" (meaning nowhere for the nvim window to
# move), change Sway focus instead
swaymsg focus "$dir" > /dev/null
