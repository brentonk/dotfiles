# Sway Configuration

Migrated from Hyprland with hy3 plugin. Managed by chezmoi.

## Directory Structure

```
~/.config/sway/
├── config                 # Main config (from chezmoi template)
├── scripts/
│   ├── nvim_sway_nav.sh   # Vim-style navigation with nvim integration
│   └── float_resize.sh    # Float toggle with terminal resize
└── CLAUDE.md
```

## Chezmoi Source Files

**Always edit these template files directly, not the generated files in `~/.config/sway/`.**

- `~/.local/share/chezmoi/dot_config/sway/config.tmpl` - Main config template
- `~/.local/share/chezmoi/dot_config/sway/scripts/executable_nvim_sway_nav.sh`
- `~/.local/share/chezmoi/dot_config/sway/scripts/executable_float_resize.sh.tmpl`

After editing, use `/chezmoi-sync` to commit and push changes.

## Key Bindings

### Core
| Binding | Action |
|---------|--------|
| `Super+Return` | Terminal (kitty) |
| `Super+C` | Kill window |
| `Super+D` | Launcher (bemenu) |
| `Super+Shift+W` | Browser (vivaldi) |
| `Super+Shift+Z` | Zathura |
| `Super+Shift+M` | Lock screen |
| `Super+Shift+P` | Screenshot (grim+slurp) |
| `Super+F` | Fullscreen toggle |
| `Super+Shift+Space` | Float toggle (resizes terminals) |

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

## Related Configs

- Waybar: `~/.config/waybar/config.jsonc` - Has both sway/* and hyprland/* modules
- Nvim plugin: `~/.config/nvim/plugin/nvim-wm-nav.lua` - Compositor-agnostic navigation
