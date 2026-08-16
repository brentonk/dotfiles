-- All colorscheme plugins live in this single file so theme changes stay in
-- one place instead of spread across per-plugin spec files.
--
-- Conventions:
--   * The flexoki spec is the fixed bootstrap: `lazy = false, priority = 1000`,
--     and its config activates whichever collection is selected (below).
--   * Every other theme stays `lazy = true`. It remains installed and can be
--     test-driven any time with `:colorscheme <name>` — lazy.nvim loads the
--     plugin on demand and runs its config/setup first.
--   * Retired themes get `enabled = false` (lazy.nvim will uninstall them on
--     `:Lazy clean`); keep their spec around in case they make a comeback.

-- Theme collections: pair this nvim colorscheme with the matching kitty
-- collection (~/.config/kitty/collections/<name>.conf). The active name is
-- read from ~/.config/theme.local (per-host, NOT chezmoi-managed); missing
-- file or unknown name falls back to flexoki-dark. Keep parsing in sync with
-- kitty's theme-collection.py.
local collections = {
  ["flexoki-dark"] = { colorscheme = "flexoki", background = "dark" },
  -- Light mode for sunny offices (kitty side: Catppuccin Latte too).
  ["catppuccin-latte"] = { colorscheme = "catppuccin-latte", background = "light" },
  -- Past daily-driver eras, resurrected from dotfiles history (dates in each
  -- kitty collections/<name>.conf header).
  ["kanagawa-dragon"] = { colorscheme = "kanagawa-dragon", background = "dark" },
  ["kanagawa-wave"] = { colorscheme = "kanagawa-wave", background = "dark" },
  ["everforest-dark"] = { colorscheme = "everforest", background = "dark" },
  ["everforest-light"] = { colorscheme = "everforest", background = "light" },
  ["catppuccin-frappe"] = { colorscheme = "catppuccin-frappe", background = "dark" },
  ["dracula"] = { colorscheme = "dracula", background = "dark" },
  ["monokai-soda"] = { colorscheme = "monokai_soda", background = "dark" },
  ["cyberdream"] = { colorscheme = "cyberdream", background = "dark" },
  ["solarized-osaka"] = { colorscheme = "solarized-osaka", background = "dark" },
  -- Reconstruction: the 2025 gruvbox era ran gruvbox-material in nvim against
  -- a community Gruvbox Dark terminal palette; the pairing never truly matched.
  ["gruvbox-material"] = { colorscheme = "gruvbox-material", background = "dark" },
}

local function active_collection()
  local path = vim.fs.joinpath(vim.fs.dirname(vim.fn.stdpath("config")), "theme.local")
  local f = io.open(path, "r")
  if not f then return collections["flexoki-dark"] end
  local name
  for line in f:lines() do
    line = vim.trim(line)
    if line ~= "" and not vim.startswith(line, "#") then
      name = line:match("%S+")
      break
    end
  end
  f:close()
  return collections[name] or collections["flexoki-dark"]
end

local active = active_collection()

return {

  -----------------------------------------------------------------------
  -- ACTIVE THEME
  -----------------------------------------------------------------------
  {
    "nuvic/flexoki-nvim",
    name = "flexoki",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = active.background
      require("flexoki").setup({
        variant = active.background == "light" and "dawn" or "moon",
        styles = {
          transparency = true,
          -- Keep theme-wide italics off (flexoki's default): italic = true here
          -- italicizes keywords/etc. in code buffers, which got too busy.
        },
        highlight_groups = {
          Comment = { italic = true },
          -- Explicitly re-enable markdown/quarto/tex *emphasis*, which the
          -- theme-wide italic = false would otherwise suppress. @markup.italic
          -- only appears in markup filetypes, so code buffers stay upright.
          ["@markup.italic"] = { italic = true },
        },
      })
      -- Non-flexoki collection schemes lazy-load via lazy.nvim's colorscheme
      -- trigger; their setup() in the specs below runs first.
      vim.cmd.colorscheme(active.colorscheme)
    end,
  },

  -----------------------------------------------------------------------
  -- ON DEMAND (`:colorscheme <name>`)
  -----------------------------------------------------------------------
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = true,
    config = function()
      require("solarized-osaka").setup({
        transparent = true,
        styles = {
          comments = { italic = true },
        },
      })
    end,
  },

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
      -- background (light/dark picks the everforest variant) is set by the
      -- collection bootstrap above, or by hand before :colorscheme everforest.
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

  {
    "scottmckendry/cyberdream.nvim",
    lazy = true,
    config = function()
      require("cyberdream").setup({
        transparent = true,
        italic_comments = true,
        borderless_pickers = false,
      })
      -- Post-colorscheme fixup (autocmd because this config runs before the
      -- triggering :colorscheme finishes applying): brighter bold separators.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "cyberdream",
        callback = function()
          vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#5ea1ff", bold = true })
        end,
      })
    end,
  },

  {
    "tanvirtin/monokai.nvim",
    lazy = true,
    config = function()
      -- Post-colorscheme fixups (autocmd because this config runs before the
      -- triggering :colorscheme finishes applying).
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "monokai*",
        callback = function()
          -- Transparent background so the terminal's opacity/toggle shows
          -- through, consistent with the other themes here.
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
      })
    end,
  },

  -----------------------------------------------------------------------
  -- RETIRED
  -----------------------------------------------------------------------
  {
    "RRethy/base16-nvim",
    enabled = false,
  },

}
