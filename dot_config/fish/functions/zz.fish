function zz --wraps='cd (fd -t d | fzf)' --description 'alias zz=cd (fd -t d | fzf)'
  set -l dir (fd -t d $argv ~ | fzf)
  and cd $dir
end
