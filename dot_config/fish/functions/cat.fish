function cat --wraps=bat --description 'bat, flagging missing trailing newlines'
  bat $argv
  set -l bat_status $status

  if isatty stdout
    for f in $argv
      string match -q -- '-*' $f; and continue
      test -f $f; or continue
      # command substitution strips a trailing newline, so non-empty = missing one
      if test -s $f; and test -n "$(tail -c1 $f)"
        echo (set_color brred)"✗ no trailing newline: $f"(set_color normal) >&2
      end
    end
  end

  return $bat_status
end
