function cmnv --wraps=nvim --description 'nvim into chezmoi picker'
  nvim -c 'lua require("telescope").extensions.chezmoi.find_files()'
end
