#!/bin/sh

# Niri navigation script with nvim integration
# Uses nvim-wm-nav plugin for seamless nvim/compositor navigation

# Usage: nvim_niri_nav.sh [direction]

dir="$1"
timeout="${NIRI_NAV_TIMEOUT:-0.1s}"

# Wrapper to run a command in nvim server, timing out if it takes too long
nvim_remote_expr() {
  timeout "$timeout" nvim --headless --server "$servername" --remote-expr "$@"
}

# Map the direction to the niri fallback action, exit with error if invalid
case "$dir" in
    left)  niri_action="focus-column-left" ;;
    right) niri_action="focus-column-right" ;;
    up)    niri_action="focus-window-up" ;;
    down)  niri_action="focus-window-down" ;;
    *)
        echo "Usage: $0 [left|right|up|down]"
        exit 1
        ;;
esac

# Get the PID of the focused window using niri msg
focused_pid="$(niri msg --json focused-window 2>/dev/null | jq -r '.pid // empty')"

# Look for a serverfile for an nvim process in the focused window
servername_file="${XDG_RUNTIME_DIR:-/tmp}/nvim-wm-nav.${focused_pid}.servername"

# If the serverfile exists, ask the associated nvim server to run the given
# navigation command
if [ -n "$focused_pid" ] && [ -f "$servername_file" ]; then
  # Read the servername from the file
  read -r servername < "$servername_file"

  # If we have a servername, run the corresponding navigation call in nvim and exit
  if [ -n "$servername" ]; then
    nvim_out="$(nvim_remote_expr "v:lua.NvimWmNav('$dir')")"
    [ "$nvim_out" = "true" ] && exit 0
  fi
fi

# If we didn't find an nvim process, or if the servername was not set, or if
# the nvim command spit back "false" (meaning nowhere for the nvim window to
# move), change niri focus instead
niri msg action "$niri_action" > /dev/null
