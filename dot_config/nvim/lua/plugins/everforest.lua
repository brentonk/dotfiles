return {
  "sainnhe/everforest",
  priority = 1000,
  config = function()
    vim.opt.background = "light"

    -- Set everforest style to 'hard'
    -- Options: 'hard', 'medium' (default), 'soft'
    vim.g.everforest_background = "hard"

    -- Enable transparent background (optional, set to 0 if you want opaque)
    vim.g.everforest_transparent_background = 1

    -- Better performance
    vim.g.everforest_better_performance = 1

    -- Not active — using cyberdream
    -- vim.cmd.colorscheme "everforest"
  end,
}
