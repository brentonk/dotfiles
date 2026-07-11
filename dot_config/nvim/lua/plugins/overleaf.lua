return {
  "richwomanbtc/overleaf.nvim",
  cmd = "Overleaf",
  build = "cd node && npm install --ignore-scripts",
  config = function()
    local opts = {
      -- Absolute path: cookie works from any cwd and stays out of the dotfiles repo
      env_file = vim.fn.stdpath("state") .. "/overleaf.env",
    }
    -- Match vimtex viewer setup: zathura on Linux, system default on macOS
    if vim.fn.has('mac') == 0 then
      opts.pdf_viewer = "zathura"
    end
    require("overleaf").setup(opts)
  end
}
