return {
	"stevearc/conform.nvim",
	opts = {
		log_level = vim.log.levels.DEBUG,
		formatters_by_ft = {
			lua = { "stylua" },
			markdown = { "prettier", "injected" },
			python = { "ruff_format" },
			quarto = { "injected" },
			r = { "air" },
			tex = { "latexindent" },
		},
		format_on_save = false,
		default_format_opts = { lsp_format = "fallback" },
		formatters = {
			-- injected = {
			-- 	options = {
			-- 		ignore_errors = true,
			-- 		lang_to_ext = {
			-- 			latex = "tex",
			-- 			python = "py",
			-- 			r = "r",
			-- 		},
			-- 	},
			-- },
		},
	},
	keys = {
		{
			"<leader>Ff",
			function()
				require("conform").format()
			end,
			desc = "Format buffer",
		},
	},
}
