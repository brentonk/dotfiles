return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'benfowler/telescope-luasnip.nvim',
  },
  opts = {
    pickers = {
      find_files = {
        follow = true,
      }
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
    vim.keymap.set('n', '<leader>cz', telescope.extensions.chezmoi.find_files, {})
  end
}
