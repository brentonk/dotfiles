#!/usr/bin/env bash
# Waybar custom module: show the current Spotify track.
# Self-contained — needs only the `playerctl` CLI (no python bindings).
# Emits one line of text: "<icon> Artist - Title", or nothing when Spotify
# isn't running / has no track, so the module collapses to zero width.

player="spotify"

# No Spotify MPRIS instance -> print nothing and exit.
status=$(playerctl --player="$player" status 2>/dev/null) || exit 0

artist=$(playerctl --player="$player" metadata artist 2>/dev/null)
title=$(playerctl --player="$player" metadata title 2>/dev/null)

# Nothing useful to show.
[ -z "$artist" ] && [ -z "$title" ] && exit 0

# Nerd Font: spotify glyph when playing, pause glyph when paused.
case "$status" in
    Playing) icon="" ;;
    Paused)  icon="" ;;
    *)       icon="" ;;
esac

if [ -n "$artist" ] && [ -n "$title" ]; then
    printf '%s %s - %s\n' "$icon" "$artist" "$title"
else
    printf '%s %s%s\n' "$icon" "$artist" "$title"
fi
