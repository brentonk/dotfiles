return {
	"epwalsh/obsidian.nvim",
	version = "*",
	lazy = true,
	ft = "markdown",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		workspaces = {
			{
				name = "personal",
				path = "~/obsidian",
			},
		},
		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},
		picker = {
			name = "telescope.nvim",
		},
		mappings = {
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			["<leader>ch"] = {
				action = function()
					return require("obsidian").util.toggle_checkbox()
				end,
				opts = { buffer = true },
			},
			["<CR>"] = {
				action = function()
					return require("obsidian").util.smart_action()
				end,
				opts = { buffer = true, expr = true },
			},
		},
	},
	keys = {
		{ "<leader>on", "<cmd>ObsidianNew<cr>", desc = "New note" },
		{ "<leader>oo", "<cmd>ObsidianOpen<cr>", desc = "Open in Obsidian" },
		{ "<leader>os", "<cmd>ObsidianSearch<cr>", desc = "Search notes" },
		{ "<leader>oq", "<cmd>ObsidianQuickSwitch<cr>", desc = "Quick switch" },
		{ "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
		{ "<leader>ot", "<cmd>ObsidianTags<cr>", desc = "Tags" },
		{ "<leader>od", "<cmd>ObsidianToday<cr>", desc = "Today's note" },
		{ "<leader>oy", "<cmd>ObsidianYesterday<cr>", desc = "Yesterday's note" },
		{ "<leader>ol", "<cmd>ObsidianLinks<cr>", desc = "Links in note" },
		{ "<leader>oe", "<cmd>ObsidianExtractNote<cr>", desc = "Extract to note", mode = "v" },
		{ "<leader>ok", "<cmd>ObsidianLink<cr>", desc = "Link selection", mode = "v" },
	},
}
