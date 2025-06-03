return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'benfowler/telescope-luasnip.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  opts = {
    pickers = {
      find_files = {
        follow = true,
      }
    },
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = 'smart_case',        -- or 'ignore_case' or 'respect_case'
      },
    }
  },
  extensions = {
    luasnip = {},
  },
  config = function(_, opts)
    local telescope = require('telescope')
    telescope.setup(opts)
    telescope.load_extension('luasnip')
    telescope.load_extension('chezmoi')
    telescope.load_extension('fzf')
    vim.keymap.set('n', '<leader>cm', telescope.extensions.chezmoi.find_files, {})
  end
}
