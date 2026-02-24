if status is-login; and status is-interactive
  set -Ua KEYS_TO_AUTOLOAD ~/.ssh/id_ed25519
  keychain --eval --quiet -Q $KEYS_TO_AUTOLOAD | source
end
