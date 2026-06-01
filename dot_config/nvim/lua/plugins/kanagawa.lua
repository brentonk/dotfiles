return {
  "rebelot/kanagawa.nvim",
  lazy = true,
  config = function()
    require("kanagawa").setup({
      transparent = true,
      commentStyle = { italic = true },
      theme = "dragon",
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
    })
    vim.cmd.colorscheme "kanagawa"
  end,
}
