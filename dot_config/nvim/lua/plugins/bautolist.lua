return {
	"brentonk/bautolist.nvim",
	branch = "develop",
	ft = { "markdown", "text", "tex", "plaintex", "quarto", "typst" },
	config = function()
		local autolist = require("autolist")
		autolist.setup({
			colon = { indent = false, indent_raw = false },
			loose_lists = true,
			lists = {
				quarto = {
					"[-+*]",    -- unordered
					"%d+[.)]",  -- digit
					"%a[.)]",   -- ascii
					"%u+[.)]",  -- roman
				},
				typst = {
					"[-+]",     -- unordered
					"%d+[.]",   -- digit
					"%a[.]",    -- ascii
				},
			},
		})

		-- Compatibility shim for bautolist versions before buffer-aware
		-- indent config (develop < 993ec51): older versions cache the
		-- *global* tabstop at setup() and treat content_indent as a single
		-- global flag, ignoring buffer-local widths and the
		-- b:autolist_content_indent override used by
		-- after/ftplugin/markdown.lua. Newer versions expose
		-- content_indent_enabled() natively and this block is skipped.
		local cfg = require("autolist.config")
		if cfg.content_indent_enabled == nil then
			local default_content_indent = cfg.content_indent
			cfg.content_indent = nil
			cfg.tabstop = nil
			cfg.tab = nil
			setmetatable(cfg, {
				__index = function(_, key)
					if key == "content_indent" then
						local override = vim.b.autolist_content_indent
						if override ~= nil then
							return override
						end
						return default_content_indent
					elseif key == "tabstop" then
						return vim.bo.expandtab and vim.bo.shiftwidth or 1
					elseif key == "tab" then
						return vim.bo.expandtab and string.rep(" ", vim.bo.shiftwidth) or "\t"
					end
				end,
			})
		end

		local filetypes = { "markdown", "text", "tex", "plaintex", "quarto", "typst" }

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

			-- <S-CR> in insert mode: soft return (continuation line aligned to content)
			vim.keymap.set("i", "<S-CR>", function()
				local cr = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
				vim.api.nvim_feedkeys(cr, "n", false)
				vim.schedule(function()
					vim.cmd("AutolistSoftReturn")
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
