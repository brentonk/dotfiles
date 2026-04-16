return {
  "folke/tokyonight.nvim",
  lazy = true,
  config = function()
    require("tokyonight").setup({
      transparent = true,
      style = "moon",
      styles = {
        comments = { italic = true },
      },
    })
    vim.cmd.colorscheme "tokyonight"
  end,
}
