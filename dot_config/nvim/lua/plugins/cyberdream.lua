return {
  "scottmckendry/cyberdream.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("cyberdream").setup({
      transparent = true,
      italic_comments = true,
      borderless_pickers = false,
    })
    vim.cmd.colorscheme "cyberdream"
    vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#5ea1ff", bold = true })
  end,
}
