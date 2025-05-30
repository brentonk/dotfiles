return {
  "mason-org/mason-lspconfig.nvim",
  opts = {
    ensure_installed = {
      "jsonls",
      "lua_ls",
      "pyright",
      "r_language_server",
      "ruff",
      "texlab",
    },
    automatic_enable = {
      exclude = {
        "lua_ls",  -- handled by nvim-lspconfig to whitelist vim global
      },
    },
  },
}
