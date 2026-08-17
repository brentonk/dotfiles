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
-- kitty's theme-collection.py. An optional `g` table holds vim.g variables
-- applied before the colorscheme (e.g. the everforest contrast variant).
local collections = {
  ["flexoki-dark"] = { colorscheme = "flexoki", background = "dark" },
  -- Light mode for sunny offices (kitty side: Catppuccin Latte too).
  ["catppuccin-latte"] = { colorscheme = "catppuccin-latte", background = "light" },
  -- Past daily-driver eras, resurrected from dotfiles history (dates in each
  -- kitty collections/<name>.conf header).
  ["kanagawa-dragon"] = { colorscheme = "kanagawa-dragon", background = "dark" },
  ["kanagawa-wave"] = { colorscheme = "kanagawa-wave", background = "dark" },
  ["everforest-dark"] = { colorscheme = "everforest", background = "dark", g = { everforest_background = "hard" } },
  ["everforest-light"] = { colorscheme = "everforest", background = "light", g = { everforest_background = "hard" } },
  ["catppuccin-frappe"] = { colorscheme = "catppuccin-frappe", background = "dark" },
  ["dracula"] = { colorscheme = "dracula", background = "dark" },
  ["monokai-soda"] = { colorscheme = "monokai_soda", background = "dark" },
  ["cyberdream"] = { colorscheme = "cyberdream", background = "dark" },
  ["solarized-osaka"] = { colorscheme = "solarized-osaka", background = "dark" },
  ["gruvbox-material"] = { colorscheme = "gruvbox-material", background = "dark" },
  -- Never daily-driven; added for completeness of each theme family.
  ["catppuccin-macchiato"] = { colorscheme = "catppuccin-macchiato", background = "dark" },
  ["catppuccin-mocha"] = { colorscheme = "catppuccin-mocha", background = "dark" },
  ["kanagawa-lotus"] = { colorscheme = "kanagawa-lotus", background = "light" },
  ["everforest-dark-medium"] = { colorscheme = "everforest", background = "dark", g = { everforest_background = "medium" } },
  ["everforest-dark-soft"] = { colorscheme = "everforest", background = "dark", g = { everforest_background = "soft" } },
  ["everforest-light-medium"] = { colorscheme = "everforest", background = "light", g = { everforest_background = "medium" } },
  ["everforest-light-soft"] = { colorscheme = "everforest", background = "light", g = { everforest_background = "soft" } },
  ["gruvbox-material-light"] = { colorscheme = "gruvbox-material", background = "light" },
  ["monokai-classic"] = { colorscheme = "monokai", background = "dark" },
  ["monokai-pro"] = { colorscheme = "monokai_pro", background = "dark" },
  ["monokai-ristretto"] = { colorscheme = "monokai_ristretto", background = "dark" },
  ["solarized-osaka-day"] = { colorscheme = "solarized-osaka-day", background = "light" },
  -- Added 2026-08-16, never daily-driven: new families whose kitty confs are
  -- official ports dumped via `kitty +kitten themes --dump-theme`.
  ["tokyonight-night"] = { colorscheme = "tokyonight-night", background = "dark" },
  ["tokyonight-storm"] = { colorscheme = "tokyonight-storm", background = "dark" },
  ["tokyonight-moon"] = { colorscheme = "tokyonight-moon", background = "dark" },
  ["tokyonight-day"] = { colorscheme = "tokyonight-day", background = "light" },
  ["rose-pine"] = { colorscheme = "rose-pine-main", background = "dark" },
  ["rose-pine-moon"] = { colorscheme = "rose-pine-moon", background = "dark" },
  ["rose-pine-dawn"] = { colorscheme = "rose-pine-dawn", background = "light" },
  ["nightfox"] = { colorscheme = "nightfox", background = "dark" },
  ["duskfox"] = { colorscheme = "duskfox", background = "dark" },
  ["nordfox"] = { colorscheme = "nordfox", background = "dark" },
  ["terafox"] = { colorscheme = "terafox", background = "dark" },
  ["carbonfox"] = { colorscheme = "carbonfox", background = "dark" },
  ["dayfox"] = { colorscheme = "dayfox", background = "light" },
  ["dawnfox"] = { colorscheme = "dawnfox", background = "light" },
  ["solarized-dark"] = { colorscheme = "solarized", background = "dark" },
  ["solarized-light"] = { colorscheme = "solarized", background = "light" },
  ["modus-operandi"] = { colorscheme = "modus_operandi", background = "light" },
  ["modus-vivendi"] = { colorscheme = "modus_vivendi", background = "dark" },
  ["nord"] = { colorscheme = "nord", background = "dark" },
  ["onedark"] = { colorscheme = "onedark", background = "dark" },
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
      for k, v in pairs(active.g or {}) do
        vim.g[k] = v
      end
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
      -- background (light/dark) and everforest_background (contrast) are set
      -- by the collection bootstrap above; default to hard for by-hand
      -- :colorscheme everforest test-drives.
      vim.g.everforest_background = vim.g.everforest_background or "hard"
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

  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    config = function()
      require("rose-pine").setup({
        styles = {
          -- Theme-wide italics off, matching the flexoki convention.
          italic = false,
          transparency = true,
        },
        highlight_groups = {
          Comment = { italic = true },
          -- Re-enable markup emphasis suppressed by italic = false (same
          -- rationale as the flexoki spec above).
          ["@markup.italic"] = { italic = true },
        },
      })
    end,
  },

  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    config = function()
      require("nightfox").setup({
        options = {
          transparent = true,
          styles = {
            comments = "italic",
          },
        },
      })
    end,
  },

  {
    "maxmx03/solarized.nvim",
    lazy = true,
    config = function()
      -- Classic Solarized (Ethan Schoonover palette); dark/light follows
      -- vim.o.background, set by the collection bootstrap.
      require("solarized").setup({
        transparent = { enabled = true },
        styles = {
          comments = { italic = true },
        },
      })
    end,
  },

  {
    "miikanissi/modus-themes.nvim",
    lazy = true,
    config = function()
      require("modus-themes").setup({
        transparent = true,
        styles = {
          comments = { italic = true },
          -- Default italicizes keywords too; keep code upright per the
          -- comments-only italics convention.
          keywords = {},
        },
      })
    end,
  },

  {
    "gbprod/nord.nvim",
    lazy = true,
    config = function()
      require("nord").setup({
        transparent = true,
        styles = {
          comments = { italic = true },
        },
      })
    end,
  },

  {
    "navarasu/onedark.nvim",
    lazy = true,
    config = function()
      require("onedark").setup({
        transparent = true,
        code_style = {
          comments = "italic",
        },
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
