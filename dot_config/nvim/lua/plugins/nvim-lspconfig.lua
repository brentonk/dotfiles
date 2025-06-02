return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    -- Lua
    lspconfig.lua_ls.setup {
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
    }
  end
}
