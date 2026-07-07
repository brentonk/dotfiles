vim.opt_local.conceallevel = 0

-- Align wrapped lines with list item text
vim.opt_local.breakindentopt = "list:-1"

-- Tab width settings (override obsidian.nvim defaults)
-- Use 4 in the Obsidian vault to match Obsidian's editor, 2 elsewhere
local obsidian_dir = vim.fs.normalize("~/obsidian")
local bufpath = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
local in_obsidian = vim.startswith(bufpath, obsidian_dir .. "/")
local width = in_obsidian and 4 or 2
vim.opt_local.shiftwidth = width
vim.opt_local.tabstop = width
vim.opt_local.softtabstop = width
vim.opt_local.expandtab = true

-- In the vault, indent nested bullets by shiftwidth (matching Obsidian)
-- instead of autolist's content-column alignment
if in_obsidian then
	vim.b.autolist_content_indent = false
end
