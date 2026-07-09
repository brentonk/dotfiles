# WezTerm Configuration

## Overview

WezTerm terminal emulator configuration. The main config file is `wezterm.lua`, managed by chezmoi as a plain file (`dot_config/wezterm/wezterm.lua`) — identical on every host.

Per-host tuning happens via unmanaged `*.local` override files next to the config (listed in `.chezmoiignore`, hot-reloaded via `add_to_config_reload_watch_list`):

- `opacity.local` — window background opacity (a bare number, 0–1)
- `font-size.local` — font size in points (a bare number)

If an override file is absent or invalid, the defaults hardcoded in `wezterm.lua` apply.

Separately from `opacity.local`, there is a **runtime opacity toggle**: `~/.config/sway/scripts/toggle_opacity.sh` (bound to a sway keybinding) rewrites a state file at `$XDG_RUNTIME_DIR/wezterm-opacity-toggle`, which wezterm watches; while it contains `opaque`, opacity is forced to 1.0, overriding both `opacity.local` and the default.

## Tech Stack

- **Language:** Lua (WezTerm config API)
- **Config management:** chezmoi (plain file, no templating)
- **Platform:** Wayland (Sway), Linux

## File Structure

- `wezterm.lua` — Main WezTerm configuration (chezmoi-managed)
- `opacity.local`, `font-size.local` — Per-host overrides (unmanaged, never add to chezmoi)
- `cyberdream.lua`, `kanagawa.lua`, `tokyonight.lua` — Alternative color schemes (chezmoi-managed, currently unused; the active scheme is wezterm's built-in `Dracula (Official)`)

## Editing

Edit `wezterm.lua` directly, then run `/chezmoi-sync` to re-add it to chezmoi and commit.

## Known Issues

### WezTerm initial render size bug on Sway (trebek)

WezTerm doesn't process Sway's initial `xdg_shell` configure event, so it renders at its default geometry (656x524) instead of the tiled size until a window manager interaction forces a redraw.

**Upstream issue:** https://github.com/wezterm/wezterm/issues/6463

**Workaround:** A `for_window` rule in the sway config template (`dot_config/sway/config.tmpl`) does a delayed fullscreen toggle to force WezTerm to repaint at the correct size. This is gated to the `trebek` host via chezmoi templating.

When the upstream issue is resolved, remove the `for_window` workaround block from the sway config template.
