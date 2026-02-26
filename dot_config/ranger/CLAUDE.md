# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Ranger file manager configuration for Arch Linux with kitty terminal. All files here are managed by chezmoi (not templates — direct edits are safe, but run `/chezmoi-sync` after changes).

## Files

- **rc.conf** — Settings and keybindings. Contains all options, aliases, browser/console/pager/taskview key mappings, and local path overrides at the bottom ("bjk customizations" section).
- **scope.sh** — File preview script (executable). Handles preview rendering by file extension, MIME type, and image display. Uses exit codes 0-7 to control ranger's preview behavior.
- **plugins/zoxide/\_\_init\_\_.py** — Zoxide integration plugin (git submodule). Provides `:z` and `:zi` commands for directory jumping.

## Chezmoi Source Paths

| Target | Chezmoi source |
|--------|---------------|
| `rc.conf` | `dot_config/ranger/rc.conf` |
| `scope.sh` | `dot_config/ranger/executable_scope.sh` |
| `plugins/zoxide/` | managed as directory (git submodule) |

None are templates, so edit target files directly.

## Key Customizations from Defaults

- **Navigation remapped for Colemak-style layout**: `hjkl` → `l` is left, `;` is right, `j`/`k` are down/up (see `copymap` lines ~427-434)
- Image preview method: **iterm2** protocol (for WezTerm compatibility)
- Column ratios: `1,3,4`
- Local sort override for `~/Dropbox/advising/`: basename, reversed

## scope.sh Exit Codes

When modifying scope.sh, these exit codes control ranger behavior:
- `0` = show stdout as preview
- `1` = no preview
- `2` = plain text
- `5` = fix both dimensions (don't reload)
- `6` = display cached image at `$IMAGE_CACHE_PATH`
- `7` = display file directly as image

## Syntax

rc.conf uses ranger's command syntax: `set`, `setlocal`, `map`, `copymap`, `cmap`, `copycmap`, `pmap`, `copypmap`, `tmap`, `copytmap`, `alias`, `eval`.
