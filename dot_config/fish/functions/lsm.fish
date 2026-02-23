function lsm --wraps='exa -lhF --color=always --icons --no-permissions --no-user --git --sort=modified' --description 'alias lsm exa sorted by modification time (oldest first)'
  exa -lhF --color=always --icons --no-permissions --no-user --git --sort=modified $argv
end
