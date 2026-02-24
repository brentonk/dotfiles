# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Fish shell configuration repository located at `~/.config/fish`. It contains custom functions, aliases, and initialization scripts for an interactive shell environment that integrates with modern CLI tools and dotfile management via chezmoi.

## Architecture

### Configuration Loading

Fish loads configuration in this order:
1. `config.fish` - Main configuration file that sets up PATH, initializes zoxide and starship, and sets EDITOR
2. `conf.d/*.fish` - Auto-loaded configuration files (e.g., `keychain.fish` for SSH key management)
3. `functions/*.fish` - Auto-loaded function definitions (loaded on-demand when called)

### Function Organization

All custom functions follow a consistent pattern:
- Each function is defined in its own file: `functions/<function_name>.fish`
- Simple aliases use `--wraps` to maintain completion support from the underlying command
### Key Integration Points

**Dotfile Management (chezmoi):**
- `cm` - Main chezmoi wrapper
- `cmlg` - Opens lazygit in the chezmoi source directory via `$(chezmoi source-path)`
- `cmnv` - Opens nvim with Telescope chezmoi picker using an autocmd

**Navigation Functions:**
- `zz` - Interactive directory navigation using `fd` + `fzf` with home directory as search root
- `dzf` - Interactive PDF opening using `fd -e pdf` + `fzf` with detached zathura

**Tool Wrappers:**
These functions override default commands with modern alternatives:
- `cat`/`less` → `bat` (syntax-highlighted file viewer)
- `ls` → `eza` with specific flags (icons, git status, directory-first grouping)
- `ssh` → sets `TERM=xterm-256color` for remote compatibility with wezterm
- `icat` → `wezterm imgcat` (image viewer in terminal)

## Testing Functions

To test a new or modified function:
```fish
# Source the function file directly
source functions/<function_name>.fish

# Or reload all functions
exec fish
```

## Creating New Functions

1. Create a new file in `functions/<function_name>.fish`
2. Use `--wraps` for simple aliases to preserve completions:
```fish
function <name> --wraps=<command> --description 'description here'
  <command> $argv
end
```

## SSH Key Management

The `conf.d/keychain.fish` script automatically loads SSH keys on login:
- Uses `keychain` to manage ssh-agent
- Auto-loads keys listed in `$KEYS_TO_AUTOLOAD`
- Only runs in login + interactive sessions

## Terminal Title

`fish_title` function customizes the terminal window title to show the full current working directory path (using `fish_prompt_pwd_dir_length=0` to disable path shortening).
