#!/usr/bin/env bash
# discover-packages.sh — Scan config directories and files for package references
# Outputs structured text with categories: mapped, unmapped, references, installed
set -euo pipefail

# ──────────────────────────────────────────────────────────────────────
# Config directory name → Arch package name mapping
# ──────────────────────────────────────────────────────────────────────
declare -A CONFIG_TO_PKG=(
  [BraveSoftware]="brave-bin"
  [Code]="code"
  [doom]="emacs"
  [doom.bak]=""
  [emacs]="emacs"
  [fish]="fish"
  [foot]="foot"
  [gh]="github-cli"
  [git]="git"
  [glow]="glow"
  [go]="go"
  [htop]="htop"
  [hypr]="hyprland"
  [i3]="i3-wm"
  [i3status]="i3status"
  [kitty]="kitty"
  [lazygit]="lazygit"
  [nnn]="nnn"
  [nvim]="neovim"
  [ranger]="ranger"
  [Slack]="slack-desktop"
  [sway]="sway"
  [vivaldi]="vivaldi"
  [waybar]="waybar"
  [wezterm]="wezterm"
  [yay]="yay"
  [zathura]="zathura"
  [chezmoi]="chezmoi"
  [obsidian]="obsidian"
  [quarto-writer]=""
  [starship.toml]="starship"
  [matplotlib]="python-matplotlib"
  [ibus]="ibus"
)

# ──────────────────────────────────────────────────────────────────────
# Config dirs that are NOT installable packages (excluded from output)
# ──────────────────────────────────────────────────────────────────────
declare -A NOT_PACKAGED=(
  [autostart]=1
  [dconf]=1
  [gtk-3.0]=1
  [github-copilot]=1
  [systemd]=1
  [user-tmpfiles.d]=1
  [mimeapps.list]=1
  [CLAUDE.md]=1
)

# ──────────────────────────────────────────────────────────────────────
# Home dotfile → package mapping
# ──────────────────────────────────────────────────────────────────────
declare -A DOTFILE_TO_PKG=(
  [.bashrc]="bash"
  [.bash_profile]="bash"
  [.bash_logout]="bash"
  [.zshrc]="zsh"
  [.zshenv]="zsh"
  [.zprofile]="zsh"
  [.Rprofile]="r"
  [.rgignore]="ripgrep"
  [.latexmkrc]="texlive-core"
  [.vimrc]="vim"
  [.Xresources]="xorg-xrdb"
  [.asoundrc]="alsa-utils"
  [.lintr]="r"
)

echo "=== MAPPED CONFIG DIRS ==="
for dir in "$HOME"/.config/*/; do
  name=$(basename "$dir")
  if [[ -n "${NOT_PACKAGED[$name]+_}" ]]; then
    continue
  fi
  if [[ -n "${CONFIG_TO_PKG[$name]+_}" ]]; then
    pkg="${CONFIG_TO_PKG[$name]}"
    if [[ -n "$pkg" ]]; then
      echo "$pkg  # from config dir: $name"
    fi
  fi
done
# Handle starship.toml (file, not dir)
if [[ -f "$HOME/.config/starship.toml" ]]; then
  echo "starship  # from config file: starship.toml"
fi

echo ""
echo "=== UNMAPPED CONFIG DIRS ==="
for dir in "$HOME"/.config/*/; do
  name=$(basename "$dir")
  if [[ -n "${NOT_PACKAGED[$name]+_}" ]]; then
    continue
  fi
  if [[ -z "${CONFIG_TO_PKG[$name]+_}" ]]; then
    echo "__UNKNOWN__  # config dir: $name"
  fi
done

echo ""
echo "=== HOME DOTFILE PACKAGES ==="
for dotfile in "${!DOTFILE_TO_PKG[@]}"; do
  if [[ -e "$HOME/$dotfile" ]]; then
    echo "${DOTFILE_TO_PKG[$dotfile]}  # from $dotfile"
  fi
done

echo ""
echo "=== CONFIG FILE REFERENCES ==="
echo "# Tools referenced in fish functions, sway config, waybar, etc."
echo "# These tools may not have their own config directories."

# Fish config.fish references
refs_found=()
if grep -q 'zoxide' "$HOME/.config/fish/config.fish" 2>/dev/null; then
  refs_found+=("zoxide  # fish config.fish: zoxide init")
fi
if grep -q 'starship' "$HOME/.config/fish/config.fish" 2>/dev/null; then
  refs_found+=("starship  # fish config.fish: starship init")
fi
if grep -q 'fnm' "$HOME/.config/fish/config.fish" 2>/dev/null; then
  refs_found+=("fnm  # fish config.fish: fnm env")
fi
if grep -q 'cargo' "$HOME/.config/fish/config.fish" 2>/dev/null; then
  refs_found+=("rust  # fish config.fish: cargo PATH")
fi

# Fish function references
if grep -ql 'bat' "$HOME/.config/fish/functions/"*.fish 2>/dev/null; then
  refs_found+=("bat  # fish functions: cat.fish, less.fish")
fi
if grep -ql 'exa\|eza' "$HOME/.config/fish/functions/"*.fish 2>/dev/null; then
  refs_found+=("eza  # fish functions: ls.fish, lsa.fish, lsm.fish")
fi
if grep -ql '\bfd\b' "$HOME/.config/fish/functions/"*.fish 2>/dev/null; then
  refs_found+=("fd  # fish functions: dzf.fish, zz.fish")
fi
if grep -ql 'fzf' "$HOME/.config/fish/functions/"*.fish 2>/dev/null; then
  refs_found+=("fzf  # fish functions: dzf.fish, zz.fish")
fi
if grep -ql 'detach' "$HOME/.config/fish/functions/"*.fish 2>/dev/null; then
  refs_found+=("detach  # fish functions: dzf.fish, dz.fish")
fi
if grep -ql 'radian' "$HOME/.config/fish/functions/"*.fish 2>/dev/null; then
  refs_found+=("# radian (pip, not pacman)  # fish functions: r.fish")
fi
if grep -ql 'kitten\|kitty' "$HOME/.config/fish/functions/"*.fish 2>/dev/null; then
  refs_found+=("kitty  # fish functions: icat.fish, ssh.fish")
fi

# Fish conf.d references
if grep -ql 'keychain' "$HOME/.config/fish/conf.d/"*.fish 2>/dev/null; then
  refs_found+=("keychain  # fish conf.d: keychain.fish")
fi

# Sway config references
if [[ -f "$HOME/.config/sway/config" ]]; then
  sway_cfg="$HOME/.config/sway/config"
  if grep -q 'bemenu' "$sway_cfg" 2>/dev/null; then
    refs_found+=("bemenu-wayland  # sway config: bemenu-run launcher")
  fi
  if grep -q 'grim' "$sway_cfg" 2>/dev/null; then
    refs_found+=("grim  # sway config: screenshot")
  fi
  if grep -q 'slurp' "$sway_cfg" 2>/dev/null; then
    refs_found+=("slurp  # sway config: region select")
  fi
  if grep -q 'brightnessctl' "$sway_cfg" 2>/dev/null; then
    refs_found+=("brightnessctl  # sway config: brightness keys")
  fi
  if grep -q 'wpctl' "$sway_cfg" 2>/dev/null; then
    refs_found+=("wireplumber  # sway config: wpctl volume control")
  fi
  if grep -q 'playerctl' "$sway_cfg" 2>/dev/null; then
    refs_found+=("playerctl  # sway config: media keys")
  fi
  if grep -q 'swaylock' "$sway_cfg" 2>/dev/null; then
    refs_found+=("swaylock  # sway config: screen lock")
  fi
  if grep -q 'dropbox' "$sway_cfg" 2>/dev/null; then
    refs_found+=("dropbox-cli  # sway config: dropbox autostart")
  fi
  if grep -q 'wl-copy\|wl-paste\|wl-clipboard' "$sway_cfg" 2>/dev/null; then
    refs_found+=("wl-clipboard  # sway config: clipboard")
  fi
  if grep -q 'jq' "$sway_cfg" 2>/dev/null || grep -rq 'jq' "$HOME/.config/sway/scripts/" 2>/dev/null; then
    refs_found+=("jq  # sway scripts: JSON processing")
  fi
fi

# Waybar references
if [[ -d "$HOME/.config/waybar" ]]; then
  if grep -rq 'pavucontrol' "$HOME/.config/waybar/" 2>/dev/null; then
    refs_found+=("pavucontrol  # waybar: audio on-click")
  fi
fi

# Print all references
for ref in "${refs_found[@]}"; do
  echo "$ref"
done

echo ""
echo "=== INSTALLED PACKAGES (pacman -Qe) ==="
echo "# Explicitly installed native packages"
pacman -Qen 2>/dev/null | awk '{print $1}'

echo ""
echo "=== INSTALLED AUR PACKAGES (pacman -Qm) ==="
echo "# Foreign/AUR packages"
pacman -Qem 2>/dev/null | awk '{print $1}'

echo ""
echo "=== NON-PACMAN TOOLS ==="
echo "# These tools are managed outside pacman and should NOT be in the install list"
echo "# radian — installed via pip (R REPL)"
echo "# stylua, prettier, etc. — managed by Mason (nvim)"
echo "# npm packages — managed by fnm/npm"
