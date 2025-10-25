return {
  "sainnhe/everforest",
  priority = 1000,
  config = function()
    -- Set the background to dark
    vim.opt.background = "dark"

    -- Set everforest style to 'hard'
    -- Options: 'hard', 'medium' (default), 'soft'
    vim.g.everforest_background = "hard"

    -- Enable transparent background (optional, set to 0 if you want opaque)
    vim.g.everforest_transparent_background = 1

    -- Better performance
    vim.g.everforest_better_performance = 1

    -- Load the colorscheme
    vim.cmd.colorscheme "everforest"
  end,
}
