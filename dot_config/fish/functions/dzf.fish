function dzf --description 'pick a PDF with fzf and open it in detached zathura'
    set -l file (fd --no-ignore -e pdf $argv | fzf)
    and begin
        zathura $file >/dev/null 2>&1 &
        disown
    end
end
