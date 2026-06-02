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

# Nerd Font / FontAwesome play-pause indicator. Use explicit codepoint
# escapes so the private-use glyphs survive editing: U+F04B play,
# U+F04C pause, U+F001 music note (fallback).
case "$status" in
    Playing) icon=$'' ;;
    Paused)  icon=$'' ;;
    *)       icon=$'' ;;
esac

# Trailing icon, matching the other right-side modules (e.g. "{volume}% {icon}").
if [ -n "$artist" ] && [ -n "$title" ]; then
    printf '%s - %s %s\n' "$artist" "$title" "$icon"
else
    printf '%s%s %s\n' "$artist" "$title" "$icon"
fi
