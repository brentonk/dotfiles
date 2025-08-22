return {
  dir = '~/Dropbox/github/bbullets',
  name = 'bbullets.nvim',
  ft = { 'markdown', 'text', 'org' }, -- Load only for these filetypes
  config = function()
    require('bbullets').setup({
      -- Bullet characters to cycle through
      bullets = { '•', '‣', '⁃', '◦' },

      -- File types where bullets are enabled by default
      filetypes = { 'markdown', 'text', 'org' },

      -- Auto-enable on supported filetypes
      auto_enable = true,

      -- Keymaps (adjusted to avoid conflicts)
      mappings = {
        toggle = '<leader>bb',
        enable = '<leader>be',
        disable = '<leader>bd',
      },

      -- Indent settings
      indent = '  ', -- 2 spaces (matches your config)

      -- Whether to create keymaps automatically
      create_mappings = true,
    })
  end,
}

