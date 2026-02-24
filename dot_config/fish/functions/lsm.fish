function lsm --wraps='eza -lhF --color=always --icons --no-permissions --no-user --git --sort=modified' --description 'alias lsm eza sorted by modification time (oldest first)'
  eza -lhF --color=always --icons --no-permissions --no-user --git --sort=modified $argv
end
