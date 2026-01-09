function lsa --wraps='exa -lhF --color=always --icons --group-directories-first --git -a' --description 'alias lsa exa -lhF --color=always --icons --group-directories-first --git -a'
  exa -lhF --color=always --icons --group-directories-first --git -a $argv

end
