function nvo --wraps=nvim --description 'nvim into obsidian picker'
  nvim -c 'autocmd VimEnter * ++once lua require("lazy").load({plugins = {"obsidian.nvim"}}) vim.cmd("ObsidianQuickSwitch")'
end
