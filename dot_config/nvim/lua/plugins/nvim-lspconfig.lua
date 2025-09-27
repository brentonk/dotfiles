return {
  "neovim/nvim-lspconfig",
  config = function()
    -- Lua LSP configuration using new vim.lsp.config specification
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = {
            globals = {
              "vim",
              -- LuaSnip injected globals
              "s",
              "t",
              "i",
              "f",
              "fmt",
              "fmta",
            },
          }
        }
      }
    })

    -- Enable the Lua language server
    vim.lsp.enable("lua_ls")
  end
}
