if status is-login
  contains $HOME/bin $PATH
  or set PATH $HOME/bin $PATH

  contains $HOME/.local/bin $PATH
  or set PATH $HOME/.local/bin $PATH

  contains $HOME/.cargo/bin $PATH
  or set PATH $HOME/.cargo/bin $PATH
end

if status is-interactive
    # Commands to run in interactive sessions can go here
    zoxide init fish | source
    starship init fish | source
    fnm env --use-on-cd | source
end

# Set editor to nvim
set -gx EDITOR nvim
