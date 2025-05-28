function ls --wraps='exa -lhF --color=always --icons --groups-directories-first --no-permissions --no-user --git' --wraps='exa -lhF --color=always --icons --group-directories-first --no-permissions --no-user --git' --description 'alias ls exa -lhF --color=always --icons --group-directories-first --no-permissions --no-user --git'
  exa -lhF --color=always --icons --group-directories-first --no-permissions --no-user --git $argv
        
end
