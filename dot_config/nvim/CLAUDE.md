# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration focused on scientific writing (LaTeX, Quarto, R, Python) with REPL-driven development workflows.

## Architecture

**Plugin Management**: lazy.nvim with plugin specs in `lua/plugins/` - each file returns a plugin spec table that lazy.nvim auto-imports.

**Key Integrations**:
- **LSP**: mason.nvim + mason-lspconfig + nvim-lspconfig (uses new `vim.lsp.config()` API)
- **Completion**: nvim-cmp with sources: vimtex, nvim_lsp, luasnip, rg, path, buffer
- **Formatting**: conform.nvim (stylua, prettier, black, air, latexindent by filetype)
- **REPL**: iron.nvim + quarto-nvim for R/Python/Quarto - uses radian for R, ipython for Python
- **Snippets**: LuaSnip with custom snippets in `snippets/lua/` and `snippets/json/`

## Custom Keybindings

Movement is remapped for right-hand ergonomics:
- `l`/`;` for left/right instead of `h`/`l`
- `h` and `,` both map to `;` (repeat find)
- `j`/`k` move visually on wrapped lines

Leader is space. Key bindings:
- `<leader>ff/fg/fb/fh` - Telescope find files/grep/buffers/help
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
- Copilot disabled for quarto and tex filetypes
- VimTeX uses zathura on Linux, Skim on macOS
