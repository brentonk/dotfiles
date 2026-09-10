return {
  'nvim-telescope/telescope.nvim',
  branch = 'master',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'benfowler/telescope-luasnip.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  opts = function()
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    -- In git_bcommits / git_bcommits_range the stock <CR> runs
    -- `git checkout <sha> -- <file>`, overwriting the working-tree file with
    -- no undo.  Make <CR> open the side-by-side diff instead (same as <C-v>),
    -- and move the checkout to <C-o> behind a confirmation prompt.
    local function confirm_checkout(prompt_bufnr)
      local entry = action_state.get_selected_entry()
      if entry == nil then
        return
      end
      local choice = vim.fn.confirm(
        string.format(
          'Overwrite %s on disk with its contents at %s?\nUncommitted changes to the file will be lost.',
          vim.fn.fnamemodify(entry.current_file, ':~:.'),
          entry.value
        ),
        '&Yes\n&No',
        2,
        'Warning'
      )
      if choice == 1 then
        actions.git_checkout_current_buffer(prompt_bufnr)
      end
    end

    local bcommits_mappings = {
      i = { ['<CR>'] = actions.select_vertical, ['<C-o>'] = confirm_checkout },
      n = { ['<CR>'] = actions.select_vertical, ['<C-o>'] = confirm_checkout },
    }

    return {
      pickers = {
        find_files = {
          follow = true,
        },
        git_bcommits = { mappings = bcommits_mappings },
        git_bcommits_range = { mappings = bcommits_mappings },
      },
      extensions = {
        fzf = {
          fuzzy = true,                    -- false will only do exact matching
          override_generic_sorter = true,  -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
          case_mode = 'smart_case',        -- or 'ignore_case' or 'respect_case'
        },
        luasnip = {},
      },
    }
  end,
  config = function(_, opts)
    local telescope = require('telescope')
    telescope.setup(opts)
    telescope.load_extension('luasnip')
    telescope.load_extension('chezmoi')
    telescope.load_extension('fzf')
    vim.keymap.set('n', '<leader>cm', telescope.extensions.chezmoi.find_files, {})
  end
}
