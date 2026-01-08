return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown", "quarto" },
  opts = {
    file_types = { "markdown", "quarto" },
    latex = {
      enabled = true,
      converter = "latex2text",
      highlight = "RenderMarkdownMath",
    },
  },
}
