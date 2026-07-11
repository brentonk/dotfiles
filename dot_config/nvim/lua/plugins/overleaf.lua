return {
  "richwomanbtc/overleaf.nvim",
  cmd = "Overleaf",
  build = "cd node && npm install --ignore-scripts",
  config = function()
    local opts = {}
    -- Match vimtex viewer setup: zathura on Linux, system default on macOS
    if vim.fn.has('mac') == 0 then
      opts.pdf_viewer = "zathura"
    end
    require("overleaf").setup(opts)
  end
}
