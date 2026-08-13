-- Locate the uv project (nearest pyproject.toml / uv.lock) containing the
-- buffer the REPL was launched from, falling back to the cwd.
local function uv_project_root(bufnr)
  local start = vim.fn.getcwd()
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" and vim.uv.fs_stat(name) then
      start = vim.fs.dirname(name)
    end
  end
  local marker = vim.fs.find({ "pyproject.toml", "uv.lock" }, { upward = true, path = start })[1]
  return marker and vim.fs.dirname(marker) or nil
end

-- Run ipython inside the project's uv environment without requiring ipython
-- to be a dependency of the project: `--with` layers it on as an ephemeral
-- overlay, and `--project` picks the environment without changing the cwd.
local function ipython_command(meta)
  local root = vim.fn.executable("uv") == 1 and uv_project_root(meta and meta.current_bufnr)
  if root then
    return { "uv", "run", "--project", root, "--with", "ipython", "ipython" }
  elseif vim.fn.executable("ipython") == 1 then
    return { "ipython" }
  elseif vim.fn.executable("uv") == 1 then
    return { "uv", "run", "--no-project", "--with", "ipython", "ipython" }
  end
  return { "python3" }
end

return {
  "Vigemus/iron.nvim",
  config = function()
    local iron = require("iron.core")
    local common = require("iron.fts.common")
    local view = require("iron.view")
    iron.setup({
      config = {
        scratch_repl = true,
        highlight = false,
        repl_definition = {
          sh = {
            command = { "zsh" },
          },
          python = {
            command = ipython_command,
            format = common.bracketed_paste,
            block_dividers = { "# %%", "#%%" },
          },
          r = {
            command = { "radian" },
            format = common.bracketed_paste,
            block_dividers = { "# %%", "#%%" },
          },
          rmd = { command = { "radian" } },
          quarto = { command = { "radian" } },
        },
        repl_filetype = function(bufnr, ft)
          return ft
        end,
        repl_open_cmd = view.split.vertical.rightbelow(100)
      },
      keymaps = {
        toggle_repl = "<leader>rr", -- toggles the repl open and closed.
        -- If repl_open_command is a table as above, then the following keymaps are
        -- available
        -- toggle_repl_with_cmd_1 = "<leader>rv",
        -- toggle_repl_with_cmd_2 = "<leader>rh",
        restart_repl = "<leader>rR", -- calls `IronRestart` to restart the repl
        send_motion = "<leader>sc",
        visual_send = "<leader>sc",
        send_file = "<leader>sf",
        send_line = "<leader>sl",
        send_paragraph = "<leader>sp",
        send_until_cursor = "<leader>su",
        send_mark = "<leader>sm",
        send_code_block = "<leader>sb",
        send_code_block_and_move = "<leader>sn",
        mark_motion = "<leader>mc",
        mark_visual = "<leader>mc",
        remove_mark = "<leader>md",
        cr = "<leader>s<cr>",
        interrupt = "<leader>s<space>",
        exit = "<leader>sq",
        clear = "<leader>cl",
      },
      ignore_blank_lines = true,
    })
  end
}
