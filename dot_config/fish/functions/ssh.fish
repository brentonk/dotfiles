function ssh --wraps=ssh --description 'SSH with proper TERM for wezterm'
  TERM=xterm-256color command ssh $argv
        
end
