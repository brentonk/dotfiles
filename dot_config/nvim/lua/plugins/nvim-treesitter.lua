return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = {
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
      },
      highlight = {
        enable = true,
      },
    })
  end
}
