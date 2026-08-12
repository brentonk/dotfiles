-- Deferred require: this spec is evaluated before conform.nvim is on the
-- runtimepath, so conform.util must not be required at spec-load time
local ruff_command = function(self, ctx)
	return require("conform.util").find_executable({ ".venv/bin/ruff" }, "ruff")(self, ctx)
end

return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			markdown = { "prettier", "injected" },
			python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
			quarto = { "injected" },
			r = { "air" },
			tex = { "latexindent" },
		},
		format_on_save = false,
		default_format_opts = { lsp_format = "fallback" },
		formatters = {
			-- Prefer the project venv's ruff (matches `uv run ruff check`) over mason's
			ruff_fix = {
				command = ruff_command,
			},
			ruff_organize_imports = {
				command = ruff_command,
			},
			ruff_format = {
				command = ruff_command,
			},
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
