return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
      "jsonls",
      "lua_ls",
      "pyright",
      "r_language_server",
      "ruff",
      "texlab",
      "tinymist",
    },
    automatic_enable = {
      exclude = {
        "lua_ls",  -- handled by nvim-lspconfig to whitelist vim global
      },
    },
  },
}
