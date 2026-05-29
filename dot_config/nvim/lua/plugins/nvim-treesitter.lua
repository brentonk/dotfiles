return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- main branch does not support lazy-loading
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "bash",
      "fish",
      "json",
      "latex",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "r",
      "typst",
      "yaml",
    })

    -- On the main branch the `highlight`/`ensure_installed` module API is gone:
    -- parsers are installed via install() above, and highlighting is started
    -- per-buffer with vim.treesitter.start(). Filetype->parser aliases
    -- (tex->latex, sh->bash, quarto/rmd->markdown, ...) are registered by
    -- nvim-treesitter's plugin/filetypes.lua and quarto-nvim's ftplugin, so
    -- get_lang() resolves correctly here. pcall guards filetypes whose parser
    -- isn't installed (or isn't built yet on first run).
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        pcall(vim.treesitter.start, args.buf)
      end,
    })
  end,
}
