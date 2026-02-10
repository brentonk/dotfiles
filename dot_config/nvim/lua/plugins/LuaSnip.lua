return {
	"L3MON4D3/LuaSnip",
	config = function()
		local luasnip = require("luasnip")
		luasnip.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
			enable_autosnippets = true,
		})

		local snippets_path_lua = vim.fn.stdpath("config") .. "/snippets/lua"
		require("luasnip.loaders.from_lua").lazy_load({
			paths = { snippets_path_lua },
		})

		-- Custom command to reload snippets
		vim.api.nvim_create_user_command("ReloadSnippets", function()
			require("luasnip.loaders.from_lua").lazy_load({
				paths = { snippets_path_lua },
			})
			print("Snippets reloaded")
		end, { force = true })
	end,
}
