function icat --wraps='kitten icat' --description 'Display images in terminal'
    if set -q KITTY_WINDOW_ID
        kitten icat $argv
    else if set -q WEZTERM_PANE
        wezterm imgcat $argv
    else
        echo "icat: no supported terminal detected (kitty or wezterm)" >&2
        return 1
    end
end
