#!/bin/sh

# Adaptation of vim-sway-nav for Hyprland

# Usage: hypr_nvim_nav.sh [direction]

dir="$1"
timeout="${HYPR_NAV_TIMEOUT:-0.1s}"

# Function to recursively search through a process tree to find the first nvim
# process, if any
get_descendent_nvim() {
  # First argument is process ID to search from
  pid="$1"

  # Look for a servername file associated with this process
  servername="${XDG_RUNTIME_DIR:-/tmp}/nvim-hypr-nav.${pid}.servername"
  if [ -f "$servername" ]; then
    echo "$servername"
    return 0
  fi

  # Otherwise, recursively search through child processes
  for child_pid in $(pgrep -P "$pid"); do
    if found_pid=$(get_descendent_nvim "$child_pid"); then
      echo "$found_pid"
      return 0
    fi
  done

  # If no process with an nvim serverfile was found, fail
  return 1
}

# Wrapper to run a command in nvim server, timing out if it takes too long
#
# Assumes that the servername environment variable has been set (this happens below)
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

# Get the ID of the focused window
focused_pid="$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid')"

# If we find an nvim process in the process tree of the focused window, ask it
# to run the given naviation command
if servername_file=$(get_descendent_nvim "$focused_pid"); then
  # Locate the corresponding servername for the nvim process
  read -r servername < "$servername_file"
  echo "Found nvim servername: $servername"

  # If we have a servername, run the corresponding navigation call in nvim and exit
  if [ -n "$servername" ]; then
    nvim_out="$(nvim_remote_expr "v:lua.NvimHyprNav('$dir')")"
    [ "$nvim_out" = "true" ] && exit 0
  fi
fi

# If we didn't find an nvim process, or if the servername was not set, or if
# the nvim command spit back "false" (meaning nowhere for the nvim window to
# move), change Hyprland focus instead
hyprctl dispatch hy3:movefocus "$dir" > /dev/null
