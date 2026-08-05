-- Session-scoped extra search directories for telescope find_files/live_grep.
-- State lives here so both init.lua and plugin/workdirs.lua can require it.

local M = {}

M.dirs = {} -- ordered absolute paths, no trailing slash

-- expand ~, absolutize, strip trailing slash (fd and fnamemodify ':p' both add one)
local function normalize(path)
  return (vim.fn.fnamemodify(vim.fn.expand(path), ':p'):gsub('/+$', ''))
end

function M.add(path)
  local dir = normalize(path)
  if vim.fn.isdirectory(dir) == 0 then
    vim.notify('Not a directory: ' .. dir, vim.log.levels.WARN)
    return false
  end
  if vim.tbl_contains(M.dirs, dir) then
    vim.notify('Already a workdir: ' .. dir, vim.log.levels.INFO)
    return false
  end
  table.insert(M.dirs, dir)
  vim.notify('Added workdir: ' .. dir)
  return true
end

function M.remove(path)
  local dir = normalize(path)
  for idx, d in ipairs(M.dirs) do
    if d == dir then
      table.remove(M.dirs, idx)
      vim.notify('Removed workdir: ' .. dir)
      return true
    end
  end
  vim.notify('Not a workdir: ' .. dir, vim.log.levels.WARN)
  return false
end

function M.clear()
  M.dirs = {}
  vim.notify('Cleared extra workdirs')
end

function M.list()
  return vim.deepcopy(M.dirs)
end

-- nil when empty so pickers get no search_dirs key and behave stock;
-- '.' keeps the cwd searched (and displayed relative) alongside the extras
function M.search_dirs()
  if #M.dirs == 0 then
    return nil
  end
  local dirs = { '.' }
  vim.list_extend(dirs, M.dirs)
  return dirs
end

function M.status()
  if #M.dirs == 0 then
    return ''
  end
  return (' (+%d dir%s)'):format(#M.dirs, #M.dirs == 1 and '' or 's')
end

-- Fuzzy picker over directories under opts.root (default: home).
-- <CR> adds the selection (or all Tab-marked selections); <C-t> toggles root home <-> /
function M.pick_add(opts)
  opts = opts or {}
  local root = opts.root or vim.uv.os_homedir()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local make_entry = require('telescope.make_entry')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local cmd = {
    'fd', '--type', 'd', '--hidden', '--follow',
    '--exclude', '.git',
    '--exclude', 'node_modules',
    '--exclude', '.cache',
    '--exclude', '__pycache__',
    '--exclude', '.venv',
  }
  if root == '/' then
    for _, e in ipairs({ 'proc', 'sys', 'dev', 'run', 'tmp', 'snap' }) do
      vim.list_extend(cmd, { '--exclude', e })
    end
  end

  pickers.new(opts, {
    prompt_title = ('Add workdir [%s]  (<C-t>: toggle root, <Tab>: multi)'):format(
      vim.fn.fnamemodify(root, ':~')
    ),
    finder = finders.new_oneshot_job(cmd, {
      cwd = root,
      entry_maker = make_entry.gen_from_file({ cwd = root }),
    }),
    sorter = conf.file_sorter(opts),
    previewer = false,
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local picker = action_state.get_current_picker(prompt_bufnr)
        local selections = picker:get_multi_selection()
        if #selections == 0 then
          selections = { action_state.get_selected_entry() }
        end
        actions.close(prompt_bufnr)
        for _, entry in ipairs(selections) do
          if entry then
            M.add(entry.path or entry.value)
          end
        end
      end)
      map({ 'i', 'n' }, '<C-t>', function()
        actions.close(prompt_bufnr)
        M.pick_add({ root = (root == '/') and vim.uv.os_homedir() or '/' })
      end)
      return true
    end,
  }):find()
end

function M.pick_remove()
  if #M.dirs == 0 then
    vim.notify('No extra workdirs set', vim.log.levels.INFO)
    return
  end
  vim.ui.select(M.list(), { prompt = 'Remove workdir:' }, function(choice)
    if choice then
      M.remove(choice)
    end
  end)
end

return M
