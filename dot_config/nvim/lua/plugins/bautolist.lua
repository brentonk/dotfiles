return {
	"brentonk/bautolist.nvim",
	branch = "develop",
	ft = { "markdown", "text", "tex", "plaintex", "quarto" },
	config = function()
		local autolist = require("autolist")
		autolist.setup({
			loose_lists = true,
			lists = {
				quarto = {
					"[-+*]", -- unordered
					"%d+[.)]", -- digit (1. 2. 3.)
					"%a[.)]", -- ascii (a) b) c))
					"%u*[.)]", -- roman (I. II. III.)
				},
			},
		})

		local filetypes = { "markdown", "text", "tex", "plaintex", "quarto" }

		local function setup_autolist_keymaps()
			local opts = { buffer = true }

			-- <Tab>: cmp visible → select next, luasnip jumpable → jump, else autolist
			vim.keymap.set("i", "<Tab>", function()
				local cmp_ok, cmp = pcall(require, "cmp")
				if cmp_ok and cmp.visible() then
					cmp.select_next_item()
					return
				end
				local luasnip_ok, luasnip = pcall(require, "luasnip")
				if luasnip_ok and luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
					return
				end
				vim.cmd("AutolistTab")
			end, opts)

			-- <S-Tab>: cmp visible → select prev, luasnip jumpable → jump back, else autolist
			vim.keymap.set("i", "<S-Tab>", function()
				local cmp_ok, cmp = pcall(require, "cmp")
				if cmp_ok and cmp.visible() then
					cmp.select_prev_item()
					return
				end
				local luasnip_ok, luasnip = pcall(require, "luasnip")
				if luasnip_ok and luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
					return
				end
				vim.cmd("AutolistShiftTab")
			end, opts)

			-- <C-l>: cycle list type in insert mode
			vim.keymap.set("i", "<C-l>", function()
				autolist.cycle_next()
			end, opts)

			-- <CR> in insert mode: check if cmp menu is visible first
			vim.keymap.set("i", "<CR>", function()
				local cmp_ok, cmp = pcall(require, "cmp")
				if cmp_ok and cmp.visible() then
					-- If completion menu visible and item selected, confirm it
					local entry = cmp.get_selected_entry()
					if entry then
						cmp.confirm({ select = false })
						return
					end
				end
				-- Otherwise, do normal enter and autolist bullet
				local cr = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
				vim.api.nvim_feedkeys(cr, "n", false)
				vim.schedule(function()
					vim.cmd("AutolistNewBullet")
				end)
			end, opts)

			vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", opts)
			vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", opts)

			-- Normal mode <CR>: only set for non-markdown filetypes
			-- (obsidian.nvim handles <CR> for markdown with smart_action)
			if vim.bo.filetype ~= "markdown" then
				vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>", opts)
			end

			vim.keymap.set("n", "<leader>ar", "<cmd>AutolistRecalculate<cr>", opts)

			-- recalculate on indent/delete
			vim.keymap.set("n", ">>", ">><cmd>AutolistRecalculate<cr>", opts)
			vim.keymap.set("n", "<<", "<<<cmd>AutolistRecalculate<cr>", opts)
			vim.keymap.set("n", "dd", "dd<cmd>AutolistRecalculate<cr>", opts)
			vim.keymap.set("v", "d", "d<cmd>AutolistRecalculate<cr>", opts)

			-- cycle list types with dot-repeat
			vim.keymap.set("n", "<leader>cn", autolist.cycle_next_dr, { buffer = true, expr = true })
			vim.keymap.set("n", "<leader>cp", autolist.cycle_prev_dr, { buffer = true, expr = true })
		end

		-- Buffer-local keymaps for autolist filetypes
		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			callback = setup_autolist_keymaps,
		})

		-- Apply keymaps to the current buffer if it's an autolist filetype
		-- (handles the buffer that triggered the lazy load)
		if vim.tbl_contains(filetypes, vim.bo.filetype) then
			setup_autolist_keymaps()
		end
	end,
}
