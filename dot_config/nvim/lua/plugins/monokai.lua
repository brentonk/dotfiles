return {
  "tanvirtin/monokai.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- "soda" palette to match WezTerm's built-in "Monokai Soda" scheme
    vim.cmd.colorscheme "monokai_soda"
    -- Transparent background so WezTerm's opacity/toggle shows through,
    -- consistent with the other themes here.
    for _, group in ipairs({
      "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer",
    }) do
      vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
  end,
}
