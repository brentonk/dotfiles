function qp --wraps='quarto preview' --description 'quarto preview bound to 127.0.0.1 (avoids localhost browser hang on office desktop)'
  # Force the IPv4 literal instead of `localhost`: Chrome on the office
  # desktop hangs/spins when pointed at http://localhost:<port>, but loads
  # http://127.0.0.1:<port> instantly. See ~/.config/OFFICE_COMPUTER_BROWSER_HANG.md
  quarto preview --host 127.0.0.1 --port 4848 $argv
end
