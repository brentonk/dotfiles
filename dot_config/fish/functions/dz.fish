function dz --wraps='zathura' --description 'open zathura detached from the terminal'
    zathura $argv >/dev/null 2>&1 &
    disown
end
