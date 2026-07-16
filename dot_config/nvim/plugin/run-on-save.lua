-- Set up module table
local M = {}

-- :RunOnSave attaches a shell command to the current buffer and reruns it
-- (asynchronously) on every save. Silent on success; vim.notify on failure.
-- :RunOnSaveOutput shows the last run's full output in a split.

local augroup = vim.api.nvim_create_augroup("RunOnSave", { clear = true })

-- Per-buffer state lives in a module table rather than vim.b because it holds
-- a live vim.SystemObj handle, which doesn't survive vim.b's serialization.
local state = {} -- [bufnr] = { cmd, cwd, autocmd_id, proc, gen, last }

-- Shared scratch buffer for :RunOnSaveOutput, created lazily
local output_buf = nil

-- Expand % / %:r / etc. with vim's expand() semantics. Use \% for a literal
-- percent sign, and %:S when the file path may contain spaces.
local function expand(cmd)
  return pcall(vim.fn.expandcmd, cmd)
end

local function display_output(res)
  local out = (res.stdout or "") .. (res.stderr or "")
  return (out:gsub("\n+$", ""))
end

-- Transient cmdline echo, truncated so it never triggers a hit-enter prompt
local function echo(msg)
  vim.api.nvim_echo({ { msg:sub(1, vim.v.echospace), "Comment" } }, false, {})
end

local function start_run(buf)
  local s = state[buf]
  if not s then
    return
  end

  local ok, expanded = expand(s.cmd)
  if not ok then
    vim.notify("RunOnSave: could not expand command: " .. s.cmd, vim.log.levels.ERROR)
    return
  end

  -- Latest save wins: kill any run still in flight. The generation counter
  -- lets the killed run's exit callback recognize it's stale, so the SIGTERM
  -- exit (code 143) never surfaces as a spurious error notification.
  if s.proc and not s.proc:is_closing() then
    s.proc:kill("sigterm")
  end
  s.gen = s.gen + 1
  local my_gen = s.gen
  local t0 = vim.uv.hrtime()

  s.proc = vim.system(
    { vim.o.shell, vim.o.shellcmdflag, expanded },
    { cwd = s.cwd, text = true },
    function(res)
      vim.schedule(function()
        local cur = state[buf]
        if not cur or my_gen ~= cur.gen then
          return
        end
        local duration = (vim.uv.hrtime() - t0) / 1e9
        cur.last = {
          cmd = expanded,
          code = res.code,
          output = display_output(res),
          when = os.date("%H:%M:%S"),
          duration = duration,
        }
        if res.code == 0 then
          echo(("RunOnSave ok (%.1fs): %s"):format(duration, expanded))
        else
          local lines = vim.split(cur.last.output, "\n")
          if #lines > 15 then
            lines = vim.list_slice(lines, 1, 15)
            table.insert(lines, "… (:RunOnSaveOutput for full output)")
          end
          vim.notify(
            ("RunOnSave failed (exit %d): %s\n%s"):format(res.code, expanded, table.concat(lines, "\n")),
            vim.log.levels.ERROR
          )
        end
      end)
    end
  )
end

local function attach(buf, cmd)
  state[buf] = state[buf] or { gen = 0 }
  local s = state[buf]
  s.cmd = cmd
  -- Capture cwd now so runs always use the directory the prompt displayed,
  -- even if the working directory changes later
  s.cwd = vim.fn.getcwd()

  -- Reuse the autocmd on re-attach so they never accumulate
  if not s.autocmd_id then
    s.autocmd_id = vim.api.nvim_create_autocmd("BufWritePost", {
      group = augroup,
      buffer = buf,
      callback = function()
        start_run(buf)
      end,
      desc = "RunOnSave: run attached shell command",
    })
  end
  echo("RunOnSave attached: " .. cmd)
end

local function detach(buf)
  local s = state[buf]
  if not s then
    echo("RunOnSave: nothing attached")
    return
  end
  if s.proc and not s.proc:is_closing() then
    s.proc:kill("sigterm")
  end
  pcall(vim.api.nvim_del_autocmd, s.autocmd_id)
  state[buf] = nil
  echo("RunOnSave detached")
end

local function prompt(buf)
  vim.ui.input({
    prompt = ("RunOnSave [%s] $ "):format(vim.fn.fnamemodify(vim.fn.getcwd(), ":~")),
    default = state[buf] and state[buf].cmd or nil,
    completion = "shellcmd",
  }, function(input)
    if input == nil then
      return -- cancelled; leave any existing attachment untouched
    elseif input == "" then
      detach(buf)
    else
      attach(buf, input)
    end
  end)
end

local function show_output(buf)
  local s = state[buf]
  if not (s and s.last) then
    echo("RunOnSave: no output yet")
    return
  end

  if not (output_buf and vim.api.nvim_buf_is_valid(output_buf)) then
    output_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[output_buf].buftype = "nofile"
    vim.bo[output_buf].bufhidden = "hide"
    vim.bo[output_buf].swapfile = false
    pcall(vim.api.nvim_buf_set_name, output_buf, "RunOnSave://output")
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = output_buf, desc = "Close RunOnSave output" })
  end

  local lines = {
    "$ " .. s.last.cmd,
    ("cwd: %s | exit %d | %s (%.1fs)"):format(
      vim.fn.fnamemodify(s.cwd, ":~"),
      s.last.code,
      s.last.when,
      s.last.duration
    ),
    string.rep("─", 40),
  }
  vim.list_extend(lines, vim.split(s.last.output, "\n"))
  vim.bo[output_buf].modifiable = true
  vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, lines)
  vim.bo[output_buf].modifiable = false

  -- Reuse a window already showing the output buffer instead of stacking splits
  local win = vim.fn.bufwinid(output_buf)
  if win ~= -1 then
    vim.api.nvim_set_current_win(win)
  else
    vim.cmd("botright split")
    vim.api.nvim_win_set_buf(0, output_buf)
    vim.api.nvim_win_set_height(0, math.min(#lines + 1, 15))
  end
end

-- The buffer-local BufWritePost autocmd dies with the buffer; only the state
-- entry needs cleanup. BufWipeout rather than BufDelete: a :bdelete'd buffer
-- can come back with the same bufnr and its autocmd intact, so its state
-- should survive too.
vim.api.nvim_create_autocmd("BufWipeout", {
  group = augroup,
  callback = function(ev)
    local s = state[ev.buf]
    if s then
      if s.proc and not s.proc:is_closing() then
        s.proc:kill("sigterm")
      end
      state[ev.buf] = nil
    end
  end,
})

vim.api.nvim_create_user_command("RunOnSave", function(opts)
  local buf = vim.api.nvim_get_current_buf()
  if opts.bang then
    detach(buf)
  elseif opts.args ~= "" then
    attach(buf, opts.args)
  else
    prompt(buf)
  end
end, {
  nargs = "?",
  bang = true,
  complete = "shellcmd",
  desc = "Attach a shell command to run on save (! or empty input to detach)",
})

vim.api.nvim_create_user_command("RunOnSaveOutput", function()
  show_output(vim.api.nvim_get_current_buf())
end, { desc = "Show last RunOnSave output in a split" })

-- Return the module table
return M
