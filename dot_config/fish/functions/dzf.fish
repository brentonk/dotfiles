function dzf --wraps='detach zathura (fzf)' --description 'alias dzf=detach zathura (fzf)'
    set -l file (fd --no-ignore -e pdf $argv | fzf)
    and detach zathura $file
end
