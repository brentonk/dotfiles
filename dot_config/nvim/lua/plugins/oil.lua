return {
	"stevearc/oil.nvim",
	opts = {},
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	lazy = true,
	cmd = { "Oil" },
	keys = {
		{ "<leader>Oo", "<cmd>Oil<cr>", desc = "Open Oil" },
		{ "<leader>Of", "<cmd>Oil --float<cr>", desc = "Open Oil in floating window" },
	},
}
