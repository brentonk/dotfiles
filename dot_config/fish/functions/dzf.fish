function dzf --wraps='detach zathura (fzf)' --description 'alias dzf=detach zathura (fzf)'
    detach zathura (fd --no-ignore -e pdf $argv | fzf)
end
