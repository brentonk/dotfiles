# Niri Configuration

The daily-driver Wayland compositor (see `~/.config/CLAUDE.md`).

## Files

- `config.kdl` — rendered from a chezmoi **template** (`dot_config/niri/config.kdl.tmpl`). **Edit the template, never the rendered file.** Niri live-reloads on change, but silently keeps the old state if the new config is invalid — always run `niri validate` after applying.
- `scripts/` — chezmoi-managed helper scripts (source files use the `executable_` prefix, e.g. `dot_config/niri/scripts/executable_toggle_opacity.sh`).

## Terminal integration

- `Mod+Return` spawns **kitty** (the primary terminal; the wezterm bind was removed July 2026).
- `Mod+Shift+T` runs `scripts/toggle_opacity.sh`, toggling background opacity for **both** wezterm (state file at `$XDG_RUNTIME_DIR/wezterm-opacity-toggle`) and kitty (per-process remote-control sockets). Sway parity: same binding exists there, but sway's own script only handles wezterm.
- Window rules exist in wezterm/kitty pairs (focus ring drawn around the translucent surface; inactive windows faded to 0.95). When adding a rule for one terminal, mirror it for the other.
