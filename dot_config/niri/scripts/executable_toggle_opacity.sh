#!/bin/sh
# Toggle terminal background opacity between the configured value and fully
# opaque, for both wezterm and kitty.
#
# wezterm: watches $XDG_RUNTIME_DIR/wezterm-opacity-toggle via its config
#   reload watch list; the literal string 'opaque' means opacity 1.0.
#   (Same state file as ~/.config/sway/scripts/toggle_opacity.sh.)
# kitty: no config watching, so drive every running instance through its
#   remote-control socket ($XDG_RUNTIME_DIR/kitty-<pid>.sock, see kitty.conf).
#
# NOTE: do not use `kitten @ set-background-opacity default` -- as of kitty
# 0.47.4 the CLI silently parses 'default' as 0 (fully transparent). Set
# explicit numeric values instead, read from kitty's own config chain.

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE="$RUNTIME_DIR/wezterm-opacity-toggle"

# Kitty's configured (translucent) opacity: kitty.local.conf overrides
# kitty.conf; last matching line in a file wins, mirroring kitty's parser.
kitty_configured_opacity() {
    for f in "$HOME/.config/kitty/kitty.local.conf" "$HOME/.config/kitty/kitty.conf"; do
        v=$(awk '$1 == "background_opacity" { v = $2 } END { print v }' "$f" 2>/dev/null)
        if [ -n "$v" ]; then
            printf '%s' "$v"
            return
        fi
    done
    printf '0.95'
}

if grep -sq opaque "$STATE" 2>/dev/null; then
    printf '' > "$STATE"        # wezterm reloads -> translucent
    kitty_opacity=$(kitty_configured_opacity)
else
    printf 'opaque' > "$STATE"  # wezterm reloads -> opaque
    kitty_opacity=1
fi

# Apply to every running kitty instance; skip stale/dead sockets quietly.
for sock in "$RUNTIME_DIR"/kitty-*.sock; do
    [ -S "$sock" ] || continue  # also false when the glob matched nothing
    kitten @ --to "unix:$sock" set-background-opacity --all "$kitty_opacity" 2>/dev/null || true
done
exit 0
