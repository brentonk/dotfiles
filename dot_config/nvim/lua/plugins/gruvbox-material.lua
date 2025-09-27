return {
  'sainnhe/gruvbox-material',
  lazy = true, -- Load on demand instead of automatically
  config = function()
    -- Optionally configure and load the colorscheme
    -- directly inside the plugin declaration.
    vim.g.gruvbox_material_enable_italic = true
    vim.g.gruvbox_material_transparent_background = 1
    -- Removed automatic colorscheme setting to allow other themes as default
    -- To use: :colorscheme gruvbox-material
  end
}
