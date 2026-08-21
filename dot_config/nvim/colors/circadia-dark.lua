-- :colorscheme shim for the circadia nvim port. The upstream repo is a
-- monorepo with the port at ports/neovim (no colors/ at the root), so
-- lazy.nvim can't lazy-load it by colorscheme name; load it explicitly here.
-- The plugin spec in plugins/COLORS.lua splices ports/neovim onto the rtp.
require("lazy").load({ plugins = { "circadia" } })
vim.cmd("highlight clear") -- the port skips this; clean up the outgoing theme
require("circadia").setup({ mode = "dark" })
