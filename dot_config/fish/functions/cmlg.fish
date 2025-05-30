function cmlg --wraps=lazygit --description 'lazygit into chezmoi repo'
  lazygit -p $(chezmoi source-path)
end
