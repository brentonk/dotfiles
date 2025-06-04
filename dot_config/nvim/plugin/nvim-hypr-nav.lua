-- Set up module table
local M = {}

-- Create a file $XDG_RUNTIME_DIR/nvim-hyp-nav.<pid>.servername that stores the
-- server name
local runtime_dir = vim.env.XDG_RUNTIME_DIR or "/tmp"
local pid = tostring(vim.fn.getpid())
M.servername_file = runtime_dir .. "/nvim-hypr-nav." .. pid .. ".servername"

-- Write the servername file on VimEnter
local augroup = vim.api.nvim_create_augroup("NvimHyprNav", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
	group = augroup,
	pattern = "*",
	callback = function()
		local servername = vim.v.servername
		if servername ~= "" then
			local file = io.open(M.servername_file, "w")
			if not file then
				vim.notify("Could not write servername file: " .. M.servername_file, vim.log.levels.ERROR)
				return
			end
			file:write(servername)
			file:close()
		end
	end,
})

-- Delete the servername file on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = augroup,
	pattern = "*",
	callback = function()
		os.remove(M.servername_file)
	end,
})

-- Function to be called from the nvim_hypr_nav.sh script that lives in the
-- Hyprland config directory
function NvimHyprNav(dir)
	-- Map directions to Vim's window navigation commands
	local dir_map = { left = "h", right = "l", up = "k", down = "j" }

	-- Check if the direction is valid
	local go_to = dir_map[dir]
	if not go_to then
		return "false"
	end

	-- Figure out where we are and where the command is trying to go
	local current_win = vim.fn.winnr()
	local target_win = vim.fn.winnr(go_to)

	-- If the movement wouldn't take us anywhere, do nothing
	-- Otherwise, move in the specified direction
	if current_win == target_win then
		return "false"
	else
		vim.cmd("wincmd " .. go_to)
		return "true"
	end
end

-- Expose the NvimHyprNav function to be callable from outside
vim.api.nvim_command("command! -nargs=1 NvimHyprNav lua NvimHyprNav(<f-args>)")

-- Return the module table
return M
