function cmnv --wraps=nvim --description 'nvim into chezmoi picker'
  nvim -c 'autocmd VimEnter * ++once lua require("telescope").extensions.chezmoi.find_files()'
end
