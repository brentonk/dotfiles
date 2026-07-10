-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- Hold the configuration
local config = wezterm.config_builder()

-- Local override files live next to this config: not chezmoi-managed, edit freely per-host
local config_dir = (os.getenv('XDG_CONFIG_HOME') or (os.getenv('HOME') .. '/.config'))
  .. '/wezterm'

-- Read a number from an override file; nil if absent or out of range
local function read_local_number(path, min, max)
  local f = io.open(path, 'r')
  if not f then return nil end
  local content = f:read('*a')
  f:close()
  local n = tonumber((content or ''):match('[%d.]+'))
  if n and n >= min and n <= max then return n end
  return nil
end

-- Fonts
local font_size_override = config_dir .. '/font-size.local'
wezterm.add_to_config_reload_watch_list(font_size_override)
config.font = wezterm.font('MonaspiceNe Nerd Font', { weight = 'Light' })
config.font_size = read_local_number(font_size_override, 4, 72) or 11.5
-- calt enables Monaspace's "texture healing" contextual alternates (kern/liga/clig are wezterm's defaults)
config.harfbuzz_features = { 'kern', 'liga', 'clig', 'calt' }

-- Color theme (use a built-in scheme; `wezterm show-keys` / docs list all names)
config.color_scheme = 'Monokai Soda'
config.hide_tab_bar_if_only_one_tab = true

-- Opacity toggle: watch a state file so sway keybinding can trigger reload
local opacity_state = (os.getenv('XDG_RUNTIME_DIR') or '/tmp') .. '/wezterm-opacity-toggle'
do
  local f = io.open(opacity_state, 'r')
  if not f then
    f = io.open(opacity_state, 'w')
    if f then f:close() end
  else
    f:close()
  end
end
wezterm.add_to_config_reload_watch_list(opacity_state)

local opacity_override = config_dir .. '/opacity.local'
wezterm.add_to_config_reload_watch_list(opacity_override)

local function is_opaque()
  local f = io.open(opacity_state, 'r')
  if f then
    local content = f:read('*a')
    f:close()
    return content:match('opaque') ~= nil
  end
  return false
end

config.window_background_opacity = is_opaque() and 1.0
  or read_local_number(opacity_override, 0, 1)
  or 0.925

-- Wayland
config.enable_wayland = true
config.use_ime = true

-- Send distinct escape sequences for modifier+key combos (CSI u / kitty encoding)
config.enable_csi_u_key_encoding = true

return config
