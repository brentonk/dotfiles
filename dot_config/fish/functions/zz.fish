function zz --wraps='cd (fd -t d | fzf)' --description 'alias zz=cd (fd -t d | fzf)'
  cd (fd -t d $argv ~ | fzf)
        
end
