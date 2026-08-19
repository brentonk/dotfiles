# Keep bat (used directly and by the cat/less wrapper functions) in sync
# with the light/dark-ness of the active theme.local collection. nvim's
# COLORS.lua `collections` registry is the single source of truth for each
# collection's background, so we read it there instead of duplicating a
# light/dark list. Resolved via XDG_CONFIG_HOME (like kitty's geninclude
# and nvim) so sandboxed runs with a fake config home behave correctly.
# ranger's preview doesn't rely on this — scope.sh recomputes the same
# thing per-preview, since ranger isn't always launched from fish.

set -l config_home ~/.config
if set -q XDG_CONFIG_HOME
    set config_home $XDG_CONFIG_HOME
end

set -l theme_name flexoki-dark
if test -f $config_home/theme.local
    set -l contents (string trim < $config_home/theme.local)
    if test -n "$contents"
        set theme_name $contents
    end
end

set -l colors_lua $config_home/nvim/lua/plugins/COLORS.lua
if test -f "$colors_lua"
    set -l entry (grep -F -- "[\"$theme_name\"]" "$colors_lua")
    if string match -q '*background = "light"*' -- "$entry"
        set -gx BAT_THEME gruvbox-light
    else
        set -ge BAT_THEME
    end
end
