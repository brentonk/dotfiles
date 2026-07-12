-- All colorscheme plugins live in this single file so theme changes stay in
-- one place instead of spread across per-plugin spec files.
--
-- Conventions:
--   * Exactly ONE spec is the active theme: `lazy = false, priority = 1000`,
--     and its config ends with `vim.cmd.colorscheme "..."`.
--   * Every other theme stays `lazy = true`. It remains installed and can be
--     test-driven any time with `:colorscheme <name>` — lazy.nvim loads the
--     plugin on demand and runs its config/setup first.
--   * To switch themes, swap which spec carries the active-theme lines.
--   * Retired themes get `enabled = false` (lazy.nvim will uninstall them on
--     `:Lazy clean`); keep their spec around in case they make a comeback.

return {

  -----------------------------------------------------------------------
  -- ACTIVE THEME
  -----------------------------------------------------------------------
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("solarized-osaka").setup({
        transparent = true,
        styles = {
          comments = { italic = true },
        },
      })
      vim.cmd.colorscheme "solarized-osaka"
    end,
  },

  -----------------------------------------------------------------------
  -- ON DEMAND (`:colorscheme <name>`)
  -----------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = true,
    config = function()
      require("tokyonight").setup({
        transparent = true,
        style = "moon",
        styles = {
          comments = { italic = true },
        },
      })
    end,
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    config = function()
      require("kanagawa").setup({
        transparent = true,
        commentStyle = { italic = true },
        theme = "dragon",
        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = "none",
              },
            },
          },
        },
      })
    end,
  },

  {
    "Mofiqul/dracula.nvim",
    lazy = true,
    config = function()
      require("dracula").setup({
        transparent_bg = true,
        italic_comment = true,
      })
    end,
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    config = function()
      require("catppuccin").setup({
        flavour = "frappe", -- latte, frappe, macchiato, mocha
        background = { -- :h background
          light = "latte",
          dark = "frappe",
        },
        transparent_background = true, -- disables setting the background color.
        show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
        term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
        dim_inactive = {
          enabled = false, -- dims the background color of inactive window
          shade = "dark",
          percentage = 0.15, -- percentage of the shade to apply to the inactive window
        },
        no_italic = false, -- Force no italic
        no_bold = false, -- Force no bold
        no_underline = false, -- Force no underline
        styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
          comments = { "italic" }, -- Change the style of comments
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
          -- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
        },
      })
    end,
  },

  {
    "sainnhe/everforest",
    lazy = true,
    config = function()
      vim.opt.background = "light"
      vim.g.everforest_background = "hard"
      vim.g.everforest_transparent_background = 1
      vim.g.everforest_better_performance = 1
    end,
  },

  {
    "sainnhe/gruvbox-material",
    lazy = true,
    config = function()
      vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_transparent_background = 1
    end,
  },

  -----------------------------------------------------------------------
  -- RETIRED
  -----------------------------------------------------------------------
  {
    "scottmckendry/cyberdream.nvim",
    enabled = false,
  },

  {
    "tanvirtin/monokai.nvim",
    enabled = false,
    lazy = true,
    config = function()
      -- Transparent background so WezTerm's opacity/toggle shows through,
      -- consistent with the other themes here.
      for _, group in ipairs({
        "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer",
      }) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
      end
      -- The soda palette paints the line-number column with an opaque base2
      -- background, so it stands out against the transparent gutter. Drop just
      -- the background while keeping each group's foreground (dim grey / orange).
      for _, group in ipairs({ "LineNr", "CursorLineNr" }) do
        local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
        hl.bg, hl.ctermbg = nil, nil
        vim.api.nvim_set_hl(0, group, hl)
      end
    end,
  },

  {
    "RRethy/base16-nvim",
    enabled = false,
  },

}
