if status is-login; and status is-interactive
  set -l keys ~/.ssh/id_ed25519
  keychain --eval --quiet -Q $keys | source
end
