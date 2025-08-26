return {
	"stevearc/oil.nvim",
	---@module 'oil'
	config = function()
		require("oil").setup({
			default_file_explorer = false,
			columns = {
				"icon",
				"mtime",
			},
			buf_options = {
				buflisted = false,
				bufhidden = "hide",
			},
			win_options = {
				wrap = false,
				signcolumn = "auto",
				cursorcolumn = false,
				foldcolumn = "0",
				spell = false,
				list = false,
				conceallevel = 3,
				concealcursor = "nvic",
			},
			delete_to_trash = false,
			skip_confirm_for_simple_edits = false,
			prompt_save_on_select_new_entry = true,
			cleanup_delay_ms = 2000,
			lsp_file_methods = {
				timeout_ms = 1000,
				autosave_changes = false,
			},
			constrain_cursor = "editable",
			experimental_watch_for_changes = false,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = {
					"actions.select",
					opts = { vertical = true },
					desc = "Open the entry in a vertical split",
				},
				["<C-h>"] = {
					"actions.select",
					opts = { horizontal = true },
					desc = "Open the entry in a horizontal split",
				},
				["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["`"] = "actions.cd",
				["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory" },
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
			},
			use_default_keymaps = true,
			view_options = {
				show_hidden = false,
				is_hidden_file = function(name, bufnr)
					return vim.startswith(name, ".")
				end,
				is_always_hidden = function(name, bufnr)
					return false
				end,
				natural_order = true,
				case_insensitive = false,
				sort = {
					{ "type", "asc" },
					{ "name", "asc" },
				},
			},
			extra_scp_args = {},
			git = {
				add = function(path)
					return false
				end,
				mv = function(src_path, dest_path)
					return false
				end,
				rm = function(path)
					return false
				end,
			},
			float = {
				padding = 2,
				max_width = 0,
				max_height = 0,
				border = "rounded",
				win_options = {
					winblend = 0,
					cursorline = false,
					signcolumn = "auto",
				},
				preview_split = "right",
				override = function(conf)
					return conf
				end,
			},
			preview = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = 0.9,
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				win_options = {
					winblend = 0,
				},
				update_on_cursor_moved = true,
			},
			progress = {
				max_width = 0.9,
				min_width = { 40, 0.4 },
				width = nil,
				max_height = { 10, 0.9 },
				min_height = { 5, 0.1 },
				height = nil,
				border = "rounded",
				minimized_border = "none",
				win_options = {
					winblend = 0,
				},
			},
			ssh = {
				border = "rounded",
			},
			keymaps_help = {
				border = "rounded",
			},
		})

		-- Auto-open preview window on cursor move
		vim.api.nvim_create_autocmd("User", {
			pattern = "OilEnter",
			callback = function(args)
				if vim.api.nvim_get_current_buf() == args.data.buf and vim.bo[args.data.buf].filetype == "oil" then
					-- Enable preview by default
					vim.schedule(function()
						require("oil.actions").preview.callback()
					end)
				end
			end,
		})

		-- Ensure visual mode works properly in oil floating windows
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "oil",
			callback = function()
				local win = vim.api.nvim_get_current_win()
				if vim.api.nvim_win_get_config(win).relative ~= "" then
					-- This is a floating window
					vim.wo[win].signcolumn = "auto"
					-- Force visible visual selection for gruvbox-material with transparency
					vim.api.nvim_set_hl(0, "Visual", {
						bg = "#504945",
						fg = "NONE",
						reverse = false,
					})
				end
			end,
		})

		-- Clean file preview without garbled output
		vim.api.nvim_create_autocmd("User", {
			pattern = "OilPreviewFile",
			callback = function(args)
				local path = args.data.path
				if not path then
					return
				end

				local filename = vim.fn.fnamemodify(path, ":t")
				local ext = vim.fn.fnamemodify(path, ":e"):lower()
				local size = vim.fn.getfsize(path)
				local size_str = size >= 0 and string.format("%.1f KB", size / 1024) or "Unknown"

				-- Get basic file info safely
				local filetype = vim.fn.system(string.format("file -b '%s' 2>/dev/null", path)):gsub("\n$", "")
				if vim.v.shell_error ~= 0 then
					filetype = "Unknown file type"
				end

				vim.api.nvim_buf_set_lines(args.data.preview_buf, 0, -1, false, {
					filename,
					"",
					"Size: " .. size_str,
					"Type: " .. filetype,
					"",
					"Press 'gx' to open in external application",
				})

				vim.bo[args.data.preview_buf].modifiable = false
				vim.bo[args.data.preview_buf].readonly = true
			end,
		})

		vim.keymap.set("n", "<leader>oo", "<cmd>Oil<cr>", { desc = "Open Oil" })
		vim.keymap.set("n", "<leader>of", "<cmd>Oil --float<cr>", { desc = "Open Oil in floating window" })
	end,
	-- Optional dependencies
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	-- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
}
