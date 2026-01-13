# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Chezmoi Management

**IMPORTANT**: This configuration is managed by chezmoi. Do not edit files in `~/.config/hypr/` directly. Instead, edit the templates in the chezmoi source directory:

```
~/.local/share/chezmoi/dot_config/hypr/
```

The main config is a template: `hyprland.conf.tmpl`

After editing, apply changes with:
```sh
chezmoi apply ~/.config/hypr/
```

## Overview

This is a Hyprland Wayland compositor configuration for Arch Linux. The setup uses:
- **hy3** plugin for i3-like manual tiling layout
- **kitty** as the default terminal
- **bemenu** as the application launcher
- **waybar** for the status bar
- **hyprpaper** for wallpaper management
- **hyprlock** for screen locking

## Key Configuration Details

### Layout System
The configuration uses the hy3 plugin (`layout = hy3`) instead of the default dwindle layout. This provides manual tiling with explicit horizontal/vertical splits:
- `SUPER+H` creates horizontal group
- `SUPER+V` creates vertical group
- `SUPER+T` toggles tabbed mode
- `SUPER+N` / `SUPER+P` cycles through tabs (with wrap)
- Window movement uses `hy3:movewindow` and focus uses `hy3:movefocus`

Tab bar styling is configured in the `plugin:hy3 { tabs { ... } }` section.

**Note**: Avoid using native Hyprland groups (`togglegroup`) with hy3 - this combination has caused kernel panics when killing grouped windows.

### Navigation Integration with Neovim
The `scripts/nvim_hypr_nav.sh` script enables seamless navigation between Hyprland windows and Neovim splits. It:
1. Checks if the focused window contains a Neovim instance by looking for serverfiles at `$XDG_RUNTIME_DIR/nvim-hypr-nav.<pid>.servername`
2. If found, sends navigation command to Neovim via `--remote-expr`
3. Falls back to `hy3:movefocus` with the `visible` flag if Neovim returns false or isn't present

The `visible` flag makes left/right navigation skip hidden tabs in tabbed groups, treating each tabbed container as a single unit. Use `SUPER+N/P` to cycle within tabs.

This requires corresponding Neovim configuration that exposes `v:lua.NvimHyprNav(direction)`.

### Smart Gaps
The configuration implements "smart gaps" - gaps are removed when only one window is visible:
- Workspace rules `w[tv1]` and `f[1]` set `gapsout:0, gapsin:0` for single-window scenarios
- `scripts/toggle_gaps.sh` manually toggles gaps on/off for the current workspace

### Custom Scripts

| Script | Purpose |
|--------|---------|
| `toggle_gaps.sh` | Toggles gaps between 0 and default values on current workspace |
| `nvim_hypr_nav.sh` | Unified navigation across Hyprland and Neovim splits |
| `float_foot_resize.sh` | Toggles floating and resizes foot/kitty terminals to 850x1200 centered |

### Input Configuration
- Caps Lock remapped to Control (`ctrl:nocaps`)
- Right Alt is compose key (`compose:ralt`)
- `follow_mouse = 2` allows scrolling unfocused windows without changing focus

## Hyprland Configuration Syntax

Config files use the hyprlang format (set vim filetype with `# vim: ft=hyprlang:`):
- Variables: `$varname = value`
- Sections: `section { ... }`
- Binds: `bind = MODIFIERS, KEY, dispatcher, args`

### Window Rules (Hyprland 0.53+)

Window rules use block syntax (the old `windowrulev2 = action, conditions` is deprecated):
```
windowrule {
    float = on
    match:class = ^brave$
}
```

Match conditions use `match:` prefix: `match:class`, `match:title`, `match:floating`, `match:xwayland`, `match:onworkspace`, etc.

## Testing Changes

After editing configuration:
```sh
# Reload hyprland config (most changes apply immediately)
hyprctl reload

# For plugin changes
hyprpm reload -n
```

Use `hyprctl` for debugging:
```sh
hyprctl activewindow -j    # JSON info about focused window
hyprctl workspacerules -j  # Current workspace rules
hyprctl getoption general:gaps_in -j  # Query config values
```
