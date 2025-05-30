return {
  "lervag/vimtex",
  lazy = false,
  ft = "tex",
  config = function()
    vim.g.vimtex_view_method = "zathura"   -- Use Zathura on Linux (adjust for macOS)
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_quickfix_open_on_warning = 0

    -- <leader>t in normal mode to toggle the TOC
    vim.api.nvim_set_keymap('n', '<leader>t', ':VimtexTocToggle<CR>', { noremap = true, silent = true })
  end
}
