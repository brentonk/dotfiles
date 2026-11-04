-- Claude Code runs in its own kitty window, not inside nvim. This plugin only
-- runs the IDE server: start `claude` in a kitty window whose cwd is inside
-- nvim's cwd, then run `/ide` (or start it with `claude --ide`) to attach.
-- Claude then sees the current file/selection, can open diffs in nvim, and
-- reads LSP diagnostics.

-- After a send (<leader>ab / <leader>as), jump to the Claude window connected
-- to this nvim. Set to false to stay in nvim.
local focus_claude_after_send = true

-- Focus the kitty window running the Claude session connected to this nvim.
-- Finds the Claude process through its socket to our server port, reads the
-- kitty IDs from its environment, selects that kitty tab/split, then focuses
-- the OS window in niri.
local function focus_claude_window()
  local port = require("claudecode").state.port
  if not port then
    return
  end

  local function run(cmd)
    local res = vim.system(cmd, { text = true }):wait()
    return res.code == 0 and res.stdout or nil
  end

  -- The Claude CLI end of the WebSocket has our server port as its peer port.
  local ss = run({ "ss", "-Htnp", "state", "established", "( dport = :" .. port .. " )" })
  local claude_pid = ss and ss:match("pid=(%d+)")
  if not claude_pid then
    return
  end

  local f = io.open("/proc/" .. claude_pid .. "/environ", "rb")
  if not f then
    return
  end
  local env = {}
  for _, kv in ipairs(vim.split(f:read("*a"), "\0", { plain = true })) do
    local k, v = kv:match("^([^=]+)=(.*)$")
    if k then
      env[k] = v
    end
  end
  f:close()

  local listen, win_id, kitty_pid = env.KITTY_LISTEN_ON, env.KITTY_WINDOW_ID, tonumber(env.KITTY_PID or "")
  if not (listen and win_id and kitty_pid) then
    return -- Claude isn't running directly in kitty (e.g. tmux, ssh)
  end

  run({ "kitty", "@", "--to", listen, "focus-window", "--match", "id:" .. win_id })
  if not vim.env.NIRI_SOCKET then
    return
  end

  local niri = run({ "niri", "msg", "--json", "windows" })
  if not niri then
    return
  end
  local candidates = vim.tbl_filter(function(w)
    return w.pid == kitty_pid
  end, vim.json.decode(niri))

  local target = candidates[1]
  if #candidates > 1 then
    -- One kitty process can own several OS windows; pick the one titled like
    -- Claude's kitty window. Ignore Claude's leading spinner glyph, which
    -- animates and can change between the two lookups.
    local function strip(s)
      return (s or ""):gsub("^[\128-\255]+%s*", "")
    end
    local ls = run({ "kitty", "@", "--to", listen, "ls", "--match", "id:" .. win_id })
    local ok, data = pcall(vim.json.decode, ls or "")
    local title = ok and data[1] and data[1].tabs[1] and data[1].tabs[1].windows[1].title
    target = nil
    for _, w in ipairs(candidates) do
      if title and strip(w.title) == strip(title) then
        target = w
        break
      end
    end
  end
  if target then
    run({ "niri", "msg", "action", "focus-window", "--id", tostring(target.id) })
  end
end

return {
  "coder/claudecode.nvim",
  -- Load at startup so the server is up before `/ide` is run in Claude.
  event = "VeryLazy",
  opts = {
    terminal = {
      provider = "none", -- no embedded terminal; server + tools only
    },
    diff_opts = {
      open_in_new_tab = true,
    },
  },
  config = function(_, opts)
    require("claudecode").setup(opts)

    if focus_claude_after_send then
      -- Fires once per file sent; collapse a multi-file send into one jump.
      local pending = false
      vim.api.nvim_create_autocmd("User", {
        pattern = "ClaudeCodeSendComplete",
        callback = function()
          if pending then
            return
          end
          pending = true
          vim.schedule(function()
            pending = false
            local ok, err = pcall(focus_claude_window)
            if not ok then
              vim.notify("claudecode: couldn't focus Claude window: " .. err, vim.log.levels.DEBUG)
            end
          end)
        end,
      })
    end
  end,
  keys = {
    { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection" },
    {
      "<leader>as",
      "<cmd>ClaudeCodeTreeAdd<cr>",
      desc = "Add file",
      ft = { "neo-tree", "oil" },
    },
    { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
    { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    { "<leader>ai", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude IDE connection status" },
  },
}
