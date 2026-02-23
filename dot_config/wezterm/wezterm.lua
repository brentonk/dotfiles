-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- Hold the configuration
local config = wezterm.config_builder()

-- Fonts
config.font = wezterm.font 'Iosevka Nerd Font'
config.font_size = 12.0

-- Color theme
config.color_scheme = 'Everforest Dark (Gogh)'
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.9

-- Wayland
config.enable_wayland = true
config.use_ime = true

return config
