-- Set up module table
local M = {}

-- Create a file $XDG_RUNTIME_DIR/nvim-hyp-nav.<pid>.servername that stores the
-- server name
local runtime_dir = vim.env.XDG_RUNTIME_DIR or "/tmp"

local function get_outermost_foot_pid()
  if not vim.env.HYPRLAND_INSTANCE_SIGNATURE then
    return nil
  end

  local pid = tostring(vim.fn.getpid())
  local last_foot
  while pid and pid ~= "1" do
    local comm = vim.fn.systemlist({ "ps", "-o", "comm=", "-p", pid })[1]
    comm = comm and vim.trim(comm)
    if comm == "foot" or comm == "footclient" then
      last_foot = pid
    end
    local ppid = vim.fn.systemlist({ "ps", "-o", "ppid=", "-p", pid })[1]
    ppid = ppid and vim.trim(ppid)
    pid = ppid
  end
  return last_foot
end

local server_pid = get_outermost_foot_pid()
if server_pid then
  M.servername_file = runtime_dir .. "/nvim-hypr-nav." .. server_pid .. ".servername"
else
  M.servername_file = nil
end

-- Write the servername file on VimEnter
local augroup = vim.api.nvim_create_augroup("NvimHyprNav", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  pattern = "*",
  callback = function()
    if not M.servername_file then
      return
    end

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
    if M.servername_file then
      os.remove(M.servername_file)
    end
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
