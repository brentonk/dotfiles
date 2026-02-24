return {
	"stevearc/oil.nvim",
	config = function()
		require("oil").setup({
    })
		vim.keymap.set("n", "<leader>Oo", "<cmd>Oil<cr>", { desc = "Open Oil" })
		vim.keymap.set("n", "<leader>Of", "<cmd>Oil --float<cr>", { desc = "Open Oil in floating window" })
	end,
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	lazy = true,
	cmd = { "Oil" },
}
