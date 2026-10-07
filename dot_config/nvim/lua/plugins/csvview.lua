-- Aligned, column-colored CSV/TSV editing via virtual text (file on disk untouched).
-- Auto-enabled for csv/tsv; :CsvViewToggle to see the raw text.
local function attach(buf)
  require("csvview").enable(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win][0].wrap = false
  end
end

return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
  opts = {
    view = {
      display_mode = "border",
      header_lnum = 1,
      sticky_header = { enabled = true },
    },
    keymaps = {
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
      jump_next_row = { "<Enter>", mode = { "n", "v" } },
      jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
  },
  config = function(_, opts)
    require("csvview").setup(opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "csv", "tsv" },
      callback = function(args) attach(args.buf) end,
    })
    -- the FileType event that triggered lazy-loading has already fired
    if vim.tbl_contains({ "csv", "tsv" }, vim.bo.filetype) then
      attach(vim.api.nvim_get_current_buf())
    end
  end,
}
