# WezTerm Configuration

## Overview

WezTerm terminal emulator configuration. The main config file is `wezterm.lua`, managed by chezmoi as a template (`dot_config/wezterm/wezterm.lua.tmpl`) with per-host customizations (e.g., opacity varies by hostname).

## Tech Stack

- **Language:** Lua (WezTerm config API)
- **Config management:** chezmoi (template with Go templating)
- **Platform:** Wayland (Sway), Linux

## File Structure

- `wezterm.lua` — Main WezTerm configuration (chezmoi-managed, do not edit directly)

## Editing

This file is managed by chezmoi as a template. Edit the source template:
```bash
chezmoi edit ~/.config/wezterm/wezterm.lua
```

Run `/chezmoi-sync` after making changes.

## Known Issues

### WezTerm initial render size bug on Sway (trebek)

WezTerm doesn't process Sway's initial `xdg_shell` configure event, so it renders at its default geometry (656x524) instead of the tiled size until a window manager interaction forces a redraw.

**Upstream issue:** https://github.com/wezterm/wezterm/issues/6463

**Workaround:** A `for_window` rule in the sway config template (`dot_config/sway/config.tmpl`) does a delayed fullscreen toggle to force WezTerm to repaint at the correct size. This is gated to the `trebek` host via chezmoi templating.

When the upstream issue is resolved, remove the `for_window` workaround block from the sway config template.
