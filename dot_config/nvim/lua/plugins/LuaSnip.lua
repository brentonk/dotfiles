return {
  "L3MON4D3/LuaSnip",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    local luasnip = require("luasnip")
    luasnip.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
      enable_autosnippets = true,
    })

    local snippets_path = vim.fn.stdpath("config") .. "/snippets"
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load({
      paths = { snippets_path },
    })

    -- Custom snippets in Lua (those that can't sensibly be in VSCode format)
    local s = luasnip.snippet
    local t = luasnip.text_node
    local i = luasnip.insert_node
    local f = luasnip.function_node
    local fmta = require("luasnip.extras.fmt").fmta
    luasnip.add_snippets("tex", {
      s({ trig = "res", dscr = "Restatable environment" },
        fmta(
          [[
          \begin{restatable}{<>}{res<>}
            \label{res:<>}
            <>
          \end{restatable}
          ]],
          {
            i(1, "environment"),
            i(2, "CommandName"),
            f(
              function(args)
                -- ChatGPT-written function for CamelCase -> kebab-case
                return args[1][1]
                    :gsub("(%l)(%u)", "%1-%2") -- fooBar → foo-Bar
                    :gsub("(%u)(%u%l)", "%1-%2") -- HTMLParser → HTML-Parser
                    :lower()
              end,
              { 2 }
            ),
            i(0, "body")
          }
        )
      ),
    })

    -- Key mappings
    vim.keymap.set({ "i", "s" }, "<Tab>", function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        -- fall back to normal tab
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
          "n",
          true
        )
      end
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { silent = true })

    -- Custom command to reload snippets
    vim.api.nvim_create_user_command("ReloadSnippets", function()
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { snippets_path },
      })
      print("Snippets reloaded")
    end, { force = true })
  end,
}
