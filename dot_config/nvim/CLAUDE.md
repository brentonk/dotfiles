# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration focused on scientific writing (LaTeX, Quarto, R, Python) with REPL-driven development workflows.

## Architecture

**Plugin Management**: lazy.nvim with plugin specs in `lua/plugins/` - each file returns a plugin spec table that lazy.nvim auto-imports.

**Color Schemes**: ALL colorscheme plugins live in the single file `lua/plugins/COLORS.lua` (a list of specs) — never create a separate per-theme plugin file. The flexoki spec is the fixed bootstrap (`lazy = false, priority = 1000`; its config activates the selected collection); the rest are `lazy = true` and load on demand via `:colorscheme <name>`; retired themes get `enabled = false`.

**Stale per-theme file footgun**: COLORS.lua absorbed what used to be per-theme spec files (monokai.lua, tokyonight.lua, kanagawa.lua, dracula.lua, everforest.lua, catppuccin.lua, gruvbox-material.lua, base16-nvim.lua, cyberdream.lua). They were removed from the chezmoi source, but `chezmoi apply`/`update` never deletes unmanaged target files, so on any host not yet cleaned up they survive as leftovers whose specs merge with COLORS.lua's (lazy.nvim merges duplicate specs for the same plugin). Symptoms: startup theme nondeterministically ignoring the collection (old monokai.lua was `lazy = false, priority = 1000` and set its own colorscheme, racing the flexoki bootstrap), or a collection's plugin silently uninstalled (old cyberdream.lua was `enabled = false`). Fix: delete every file in `lua/plugins/` that `chezmoi source-path` reports as "not managed" and that duplicates a plugin declared in COLORS.lua. Cleaned on the work desktop 2026-08-17; likely still pending on other hosts (e.g. trebek).

**Theme collections**: COLORS.lua opens with a `collections` registry mapping a collection name to `{ colorscheme, background }`; each entry pairs with a kitty palette at `kitty/collections/<name>.conf`. The active name is read from `~/.config/theme.local` (per-host, NOT chezmoi-managed — switching a machine never touches the repo); missing file or unknown name falls back to `flexoki-dark`. To add a collection: add a registry entry (plus a `lazy = true` plugin spec if the scheme is new) and the matching kitty collection file.

**Key Integrations**:
- **LSP**: mason.nvim + mason-lspconfig + nvim-lspconfig (uses new `vim.lsp.config()` API)
- **Completion**: nvim-cmp with sources: vimtex, nvim_lsp, luasnip, rg, path, buffer
- **Formatting**: conform.nvim (stylua, prettier, black, air, latexindent by filetype)
- **REPL**: iron.nvim + quarto-nvim for R/Python/Quarto - uses radian for R, ipython for Python
- **Snippets**: LuaSnip with custom snippets in `snippets/lua/`

## Custom Keybindings

Movement is remapped for right-hand ergonomics:
- `l`/`;` for left/right instead of `h`/`l`
- `h` and `,` both map to `;` (repeat find)
- `j`/`k` move visually on wrapped lines

Leader is space. Key bindings:
- `<leader>ff/fg/fb/fh/fs` - Telescope find files/grep/buffers/help/workspace symbols
- `<leader>rs/rr/rf/rh` - Iron REPL start/restart/focus/hide
- `<leader>sc/sl/sp/sf` - Iron send motion/line/paragraph/file
- `<leader>rc/ra/rA/rl` - Quarto run cell/above/all/line
- `<leader>Oo/Of` - Oil file browser/float
- `<leader>cm` - Telescope chezmoi files
- `gf/gq/gF` - LSP format line/paragraph/buffer

## Snippets

Custom LuaSnip snippets use globals injected by LuaSnip: `s`, `t`, `i`, `f`, `fmt`, `fmta`. The lua_ls config whitelists these. Reload with `:ReloadSnippets`.

## List Handling

autolist.nvim provides automatic list continuation for markdown/quarto/tex. Press Enter to continue lists, Tab/S-Tab to indent, `<leader>cn`/`<leader>cp` to cycle list types.

## File Type Handling

- `.txt` files are treated as markdown
- Spell checking enabled for markdown, quarto, tex
- VimTeX uses zathura on Linux, Skim on macOS
