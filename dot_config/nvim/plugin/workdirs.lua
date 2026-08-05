-- User commands and keymaps for session-scoped telescope workdirs (lua/workdirs.lua)

local wd = require('workdirs')

vim.api.nvim_create_user_command('WorkdirAdd', function(opts)
  if opts.args == '' then
    wd.pick_add()
  else
    wd.add(opts.args)
  end
end, { nargs = '?', complete = 'dir', desc = 'Add an extra search workdir (no arg: fuzzy picker)' })

vim.api.nvim_create_user_command('WorkdirRemove', function(opts)
  if opts.args == '' then
    wd.pick_remove()
  else
    wd.remove(opts.args)
  end
end, {
  nargs = '?',
  complete = function()
    return wd.list()
  end,
  desc = 'Remove an extra search workdir',
})

vim.api.nvim_create_user_command('WorkdirClear', function()
  wd.clear()
end, { desc = 'Clear all extra search workdirs' })

vim.api.nvim_create_user_command('WorkdirList', function()
  local dirs = wd.list()
  if #dirs == 0 then
    vim.notify('No extra workdirs set')
  else
    vim.notify('Extra workdirs:\n' .. table.concat(dirs, '\n'))
  end
end, { desc = 'List extra search workdirs' })

vim.keymap.set('n', '<leader>fa', wd.pick_add, { desc = 'Add search workdir' })
vim.keymap.set('n', '<leader>fw', wd.pick_remove, { desc = 'Remove search workdir' })
