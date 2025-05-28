return {
  "bullets-vim/bullets.vim",
  -- load only for the file-types we care about
  ft = { "markdown", "text", "gitcommit", "quarto" },

  init = function()
    -- enable the plugin for those file-types
    vim.g.bullets_enabled_file_types = {
      "markdown",
      "text",
      "gitcommit",
      "quarto",
    }

    ------------------------------------------------------------------
    -- Optional quality-of-life tweaks.  Uncomment / adjust as needed.
    ------------------------------------------------------------------

    -- 1. Keep your <CR> mapping from nvim-cmp (or other completion) intact
    --    and use Meta-b + <CR> for a new list item instead.
    -- vim.g.bullets_set_mappings   = 0
    -- vim.g.bullets_mapping_leader = "<M-b>"

    -- 2. Delete a trailing empty bullet automatically
    -- vim.g.bullets_delete_last_bullet_if_empty = 1

    -- 3. Put a blank line between list items
    vim.g.bullets_line_spacing = 2

    vim.g.bullets_outline_levels = { 'num', 'std-' }
  end,
}

