-- kaarmu/typst.vim is here for one thing: its conceal support, which shows
-- `alpha` as α, `->` as →, etc. in Typst math mode (like vimtex's conceal for
-- TeX). Highlighting itself still comes from treesitter; the conceal lives in
-- typst.vim's syntax file, which vim.treesitter.start() turns off, so
-- after/ftplugin/typst.lua switches regex syntax back on for typst buffers.
return {
  "kaarmu/typst.vim",
  ft = "typst",
  init = function()
    -- Read by syntax/typst.vim when it is sourced, so must be set before load.
    vim.g.typst_conceal_math = 1
    -- Don't let its ftplugin override indent options; init.lua sets them.
    vim.g.typst_recommended_style = 0
    -- vim.g.typst_conceal_emoji = 1 -- `#emoji.alien` -> 👽
  end,
}
