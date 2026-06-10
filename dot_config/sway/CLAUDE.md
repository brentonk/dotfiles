# Sway Configuration

Migrated from Hyprland with hy3 plugin. Managed by chezmoi.

## Directory Structure

```
~/.config/sway/
├── config                 # Main config (from chezmoi template)
├── scripts/
│   ├── nvim_sway_nav.sh   # Vim-style navigation with nvim integration
│   ├── float_resize.sh    # Float toggle with terminal resize
│   └── toggle_opacity.sh  # Toggle wezterm background opacity
└── CLAUDE.md
```

## Chezmoi Source Files

**Always edit these template files directly, not the generated files in `~/.config/sway/`.**

- `~/.local/share/chezmoi/dot_config/sway/config.tmpl` - Main config template
- `~/.local/share/chezmoi/dot_config/sway/scripts/executable_nvim_sway_nav.sh`
- `~/.local/share/chezmoi/dot_config/sway/scripts/executable_float_resize.sh.tmpl`
- `~/.local/share/chezmoi/dot_config/sway/scripts/executable_toggle_opacity.sh`

After editing, use `/chezmoi-sync` to commit and push changes.

## Key Bindings

### Core
| Binding | Action |
|---------|--------|
| `Super+Return` | Terminal (wezterm) |
| `Super+C` | Kill window |
| `Super+D` | Launcher (bemenu) |
| `Super+Shift+W` | Browser (chromium) |
| `Super+Shift+Z` | Zathura |
| `Super+Shift+M` | Lock screen |
| `Super+Shift+P` | Screenshot (grim+slurp) |
| `Super+F` | Fullscreen toggle |
| `Super+Shift+Space` | Float toggle (resizes terminals) |
| `Super+Shift+T` | Toggle wezterm opacity (transparent/opaque) |
| `Super+S` | Toggle Spotify dedicated scratchpad (launches if not running) |
| `Super+O` | Toggle Obsidian dedicated scratchpad (launches if not running) |

### Navigation (vim-style, integrates with nvim splits)
| Binding | Direction |
|---------|-----------|
| `Super+L` | Left |
| `Super+;` | Right |
| `Super+K` | Up |
| `Super+J` | Down |

### Window Movement
| Binding | Direction |
|---------|-----------|
| `Super+Shift+L` | Move left |
| `Super+Shift+;` | Move right |
| `Super+Shift+K` | Move up |
| `Super+Shift+J` | Move down |

### Layout (hy3 equivalents)
| Binding | Action |
|---------|--------|
| `Super+H` | Horizontal split |
| `Super+V` | Vertical split |
| `Super+T` | Toggle stacking/split |
| `Super+N` | Focus next (right) |
| `Super+P` | Focus previous (left) |

### Workspaces
- `Super+1-0` - Switch to workspace
- `Super+Shift+1-0` - Move window to workspace

### Scratchpad
- `Super+Minus` - Show scratchpad
- `Super+Shift+Minus` - Move to scratchpad

### Dedicated scratchpads (Spotify / Obsidian)

`Super+S` and `Super+O` toggle Spotify and Obsidian as dedicated scratchpad
apps. Mechanism:

- `for_window [app_id="spotify|obsidian"]` rules send each app to the
  scratchpad on launch, then show it floating at 75%×85%, centered.
- The bindings run `swaymsg '[app_id=...] scratchpad show' || <launch cmd>` —
  `swaymsg` exits non-zero when no window matches, so the app is launched if
  not running, toggled otherwise. The Obsidian launch command is host-templated
  (`$obsidian` variable: version-pinned AppImage on Ubuntu, `obsidian` on Arch).
- Waybar shows per-app indicators (`custom/scratch-spotify`,
  `custom/scratch-obsidian` in `~/.config/waybar/config.jsonc`), driven by
  `~/.config/waybar/scratchpad_indicator.sh` (event-driven via
  `swaymsg -t subscribe`). Icon in brand color when the window is visible,
  dimmed when stashed, absent when the app isn't running. Clicking the
  indicator toggles, same as the keybinding. Obsidian has no official Nerd
  Fonts glyph yet, so it uses `nf-md-diamond_stone` (U+F01C8).

## Nvim Integration

The navigation scripts work with `~/.config/nvim/plugin/nvim-wm-nav.lua` which:
1. Creates a serverfile at `$XDG_RUNTIME_DIR/nvim-wm-nav.<pid>.servername`
2. Navigation script checks for this file and tries nvim navigation first
3. Falls back to sway focus if nvim can't navigate (at edge of splits)

Works with any supported Wayland compositor (checks for `SWAYSOCK` or `HYPRLAND_INSTANCE_SIGNATURE`).

## Differences from Hyprland

- No rounded corners (Sway limitation)
- No animations
- Uses `swaylock` instead of `hyprlock`
- Uses `grim`+`slurp` instead of `grimblast`
- Stacking layout instead of hy3 tabs (similar behavior)

## Chromium dialog floating (cross-distro / Arch note)

The window rules float Chromium's file Open/Save/folder dialogs but not normal
windows. This is done by **title-matching**, which looks hacky but is forced by
Wayland:

- Chromium gives its dialogs the **same `app_id` (`chromium`)** as ordinary
  windows, so app_id alone can't distinguish them.
- This Chromium build (v148, both xtradeb deb and Arch's package) has **no
  xdg-desktop-portal file chooser** — `GTK_USE_PORTAL` and any
  `--use-*-file-picker` flag are absent from the binary. So the dialogs are NOT
  portal windows; you can't match them via `app_id="xdg-desktop-portal-gtk"`.
  Don't try to "fix" this by adding portal flags — they don't exist for file
  selection on Chromium yet.
- Sway's `window_type=` / `window_role=` criteria are **X11-only** and never
  match native-Wayland Chromium, so the old `window_type="dialog"` rule was dead.

Titles are the only lever. The rule is anchored (`^...$`); it can't false-match a
web page because real browser windows always end in ` - Chromium` while dialogs
have bare titles. (The previous `title="^Settings.*"` rule used a prefix match,
which floated every site whose page title started with "Settings" — that was the
bug.)

**Arch compatibility:** the rule uses only `app_id="chromium"` + Chromium's own
dialog title strings, both identical across Arch and Ubuntu, so it should work on
Arch unchanged — no portal/distro dependency. **To verify on an Arch machine:**
open a file dialog in Chromium, then run

```
swaymsg -t get_tree | grep -E '"app_id"|"name"'
```

If the dialog's title isn't already in the `for_window [app_id="chromium"
title="^(...)$"]` alternation, add it there (exact, anchored). Locale matters —
non-English Chromium will use translated titles.

**Also note the `$mod+Shift+b` binding** runs `bjkhome_chromium` (a PATH launcher
that opens chromium as an app to bjkhome.pages.dev). On Ubuntu that's
`~/bin/bjkhome_chromium -> ~/Dropbox/bin/bjkhome_ubuntu`. On Arch, make sure an
equivalent `bjkhome_chromium` exists in PATH and points at `chromium`, or the
binding will fail (it was renamed from the old `bjkhome_brave`).

## Related Configs

- Waybar: `~/.config/waybar/config.jsonc` - Has both sway/* and hyprland/* modules
- Nvim plugin: `~/.config/nvim/plugin/nvim-wm-nav.lua` - Compositor-agnostic navigation
