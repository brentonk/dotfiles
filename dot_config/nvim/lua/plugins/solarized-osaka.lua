return {
  "craftzdog/solarized-osaka.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("solarized-osaka").setup({
      transparent = true,
      styles = {
        comments = { italic = true },
      },
    })
    vim.cmd.colorscheme "solarized-osaka"
  end,
}
