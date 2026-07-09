return {
  "Mofiqul/dracula.nvim",
  lazy = true,
  config = function()
    require("dracula").setup({
      transparent_bg = true,
      italic_comment = true,
    })
    vim.cmd.colorscheme "dracula"
  end,
}
