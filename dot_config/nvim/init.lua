-- <space> as leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- lazy.nvim
require("config.lazy")

-- true color
vim.opt.termguicolors = true

-- insert newline at end of file
vim.opt.fixendofline = true

-- indentation and wrapping
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.wrap       = true
vim.opt.linebreak  = true
vim.opt.breakindent = true

-- don't continue comments on carriage return
-- reddit says gotta do it this hackish way:
-- https://www.reddit.com/r/neovim/comments/13585hy/trying_to_disable_autocomments_on_new_line_eg/
vim.cmd('autocmd BufEnter * set formatoptions-=cro')
vim.cmd('autocmd BufEnter * setlocal formatoptions-=cro')

-- line numbers + gutter
vim.opt.number = true
vim.opt.signcolumn = "yes"

-- hold leader key for 3 seconds
vim.opt.timeoutlen = 3000

-- set lines of context when scrolling
vim.opt.scrolloff = 3

-- esc un-highlights after search
vim.keymap.set("n", "<Esc>", "<Esc>:noh<CR>", { noremap = true })

-- case insensitive search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- allow reading file type from modeline
vim.opt.modeline = true

-- title string for terminal should be current path
vim.opt.title = true
vim.opt.titlelen = 0
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local pwd = os.getenv("PWD") or vim.loop.cwd()
    local rel = vim.fn.expand("%:.")
    local display
    if rel == "" then
      display = pwd
    else
      display = pwd .. "/" .. rel
    end
    display = display:gsub(vim.env.HOME, "~", 1)
    vim.opt.titlestring = "nvim " .. display
  end,
})

-- Movement key remapping for right-hand ergonomics
-- Use l/; for left/right instead of h/l
vim.keymap.set({"n", "x"}, "l", "h", { noremap = true })
vim.keymap.set({"n", "x"}, ";", "l", { noremap = true })
vim.keymap.set({"n", "x"}, "h", ";", { noremap = true })
vim.keymap.set({"n", "x"}, ",", ";", { noremap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<C-l>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<C-;>", "<C-w>l", { noremap = true })

-- Move visually when lines are wrapped
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

-- alt+backspace to delete word
vim.keymap.set("i", "<M-BS>", "<C-w>", { noremap = true })

-- enable spell checking for markdown, quarto, and latex
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "quarto", "tex" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us" }
  end,
})

-- telescope key bindings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- iron REPL key bindings
vim.keymap.set("n", "<leader>rs", "<cmd>IronRepl<CR>", {desc="Open REPL"})
vim.keymap.set("n", "<leader>rr", "<cmd>IronRestart<CR>", {desc="Restart REPL"})
vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<CR>", {desc="Focus REPL"})
vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<CR>", {desc="Hide REPL"})

-- LSP key bindings
vim.keymap.set('n', 'gf', function()
  -- get current line (0-indexed) and full width
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  vim.lsp.buf.format({
    -- pass a range covering only this line
    range = {
      start = { row, 0 },
      ['end'] =   { row, math.huge },
    },
  })
end, { desc = "LSP format current line", silent = true })
vim.keymap.set('v', 'gf', function()
  -- get visual start/end marks
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")
  vim.lsp.buf.format({
    -- convert to 0-indexed { line, col }
    range = {
      start = { s[2] - 1, s[3] - 1 },
      ['end'] = { e[2] - 1, e[3] - 1 },
    },
  })
end, { desc = "LSP format selected range", silent = true })
vim.keymap.set('n', 'gq', function()
  -- 1) save cursor
  local win = vim.api.nvim_get_current_win()
  local cur = vim.api.nvim_win_get_cursor(win)

  -- 2) select paragraph
  vim.cmd('normal! vip')

  -- 3) grab the start/end of that visual selection
  local s = vim.fn.getpos("'<")
  local e = vim.fn.getpos("'>")

  -- 4) ask the LSP to format only that range (line/col are 0-indexed)
  vim.lsp.buf.format({
    range = {
      start = { s[2] - 1, s[3] - 1 },
      ['end'] = { e[2] - 1, e[3] - 1 },
    },
  })

  -- 5) restore cursor (and exit any leftover visual mode)
  -- vim.cmd('normal! <Esc>')
  vim.api.nvim_win_set_cursor(win, cur)
  vim.cmd('noh') -- clear any highlights
end, {
  desc    = "LSP format current paragraph",
  silent  = true,
  noremap = true,
})
vim.keymap.set('n', 'gF', vim.lsp.buf.format, { desc = "LSP format current buffer", silent = true })

-- Use Ctrl+\ to exit terminal mode
vim.keymap.set("t", "<C-\\>", "<C-\\><C-n>", { noremap = true })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { noremap = true })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { noremap = true })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>h", { noremap = true })
vim.keymap.set("t", "<C-;>", "<C-\\><C-n><C-w>l", { noremap = true })

-- R: don't indent like ESS
vim.g.r_indent_align_args    = 0
vim.g.r_indent_ess_comments  = 0
vim.g.r_indent_ess_compatible = 0


