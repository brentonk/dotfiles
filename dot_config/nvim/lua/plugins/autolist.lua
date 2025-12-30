return {
	"gaoDean/autolist.nvim",
	ft = { "markdown", "text", "tex", "plaintex", "quarto" },
	config = function()
		local autolist = require("autolist")
		autolist.setup({
			lists = {
				quarto = {
					"[-+*]",    -- unordered
					"%d+[.)]",  -- digit (1. 2. 3.)
					"%a[.)]",   -- ascii (a) b) c))
					"%u*[.)]",  -- roman (I. II. III.)
				},
			},
		})

		local filetypes = { "markdown", "text", "tex", "plaintex", "quarto" }

		local function setup_autolist_keymaps()
			local opts = { buffer = true }
			vim.keymap.set("i", "<tab>", "<cmd>AutolistTab<cr>", opts)
			vim.keymap.set("i", "<s-tab>", "<cmd>AutolistShiftTab<cr>", opts)
			vim.keymap.set("i", "<CR>", "<CR><cmd>AutolistNewBullet<cr>", opts)
			vim.keymap.set("n", "o", "o<cmd>AutolistNewBullet<cr>", opts)
			vim.keymap.set("n", "O", "O<cmd>AutolistNewBulletBefore<cr>", opts)
			vim.keymap.set("n", "<CR>", "<cmd>AutolistToggleCheckbox<cr><CR>", opts)
			vim.keymap.set("n", "<C-r>", "<cmd>AutolistRecalculate<cr>", opts)

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
