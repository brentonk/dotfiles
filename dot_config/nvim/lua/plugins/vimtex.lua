return {
  "lervag/vimtex",
  ft = "tex",
  config = function()
    -- Platform-specific PDF viewer setup
    if vim.fn.has('mac') == 1 then
      vim.g.vimtex_view_method = "skim"
    else
      vim.g.vimtex_view_method = "zathura"
    end
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_indent_lists = {} -- disable weird hanging indent in lists
    vim.g.vimtex_toc_config = {
      layer_status = {
        label = 0
      },
      show_help = 0,
      todo_sorted = 0,
    }


    vim.api.nvim_create_autocmd("FileType", {
      pattern = "tex",
      callback = function()
        -- <leader>t in normal mode to toggle the TOC
        vim.keymap.set('n', '<leader>t', ':VimtexTocToggle<CR>', { buffer = true, noremap = true, silent = true })

        -- S to surround selection with an environment
        vim.keymap.set("x", "S", "<plug>(vimtex-env-surround-visual)", { buffer = true, silent = true })

        -- S to surround current line with an environment
        vim.keymap.set("n", "S", "<plug>(vimtex-env-surround-line)", { buffer = true, silent = true })
      end,
    })
  end
}
