function dzf --wraps='detach zathura (fzf)' --description 'alias dzf=detach zathura (fzf)'
    detach zathura (fd -e pdf $argv | fzf)
end
