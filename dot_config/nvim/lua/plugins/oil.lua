return {
	"stevearc/oil.nvim",
	opts = {
		default_file_explorer = true,
		keymaps = {
			["<C-p>"] = { "actions.preview", opts = { horizontal = true } },
		},
		preview_win = { preview_method = "load" },
	},
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	lazy = false,
	keys = {
		{ "<leader>Oo", "<cmd>Oil<cr>", desc = "Open Oil" },
		{ "<leader>Of", "<cmd>Oil --float<cr>", desc = "Open Oil in floating window" },
	},
}
