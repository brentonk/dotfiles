function ls --wraps='eza -lhF --color=always --icons --group-directories-first --no-permissions --no-user --git' --description 'alias ls eza -lhF --color=always --icons --group-directories-first --no-permissions --no-user --git'
  eza -lhF --color=always --icons --group-directories-first --no-permissions --no-user --git $argv
end
