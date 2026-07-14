# Kitty Configuration

Primary terminal as of July 2026 (`Mod+Return` in niri; wezterm is secondary).

## Files

- `kitty.conf` — rendered from a chezmoi **template** (`dot_config/kitty/kitty.conf.tmpl`) with `{{ .chezmoi.hostname }}` conditionals for fonts, font size, and background opacity. **Edit the template, never the rendered file.**
- `current-theme.conf` — chezmoi-managed (plain). Flexoki Dark, from the mbadolato/iTerm2-Color-Schemes kitty port — the same collection wezterm's built-in `flexoki-dark` derives from, so the two terminals' palettes match exactly. The `BEGIN_KITTY_THEME`/`END_KITTY_THEME` markers in `kitty.conf` are managed by `kitten themes`; if that tool is ever re-run, re-add both files to chezmoi.
- `kitty.local.conf` — per-host overrides (font size, opacity, anything), loaded **last** via `globinclude` so it wins over everything. NOT chezmoi-managed (listed in `.chezmoiignore`) — never add it. Mirrors wezterm's `*.local` convention.
- `kitty.conf.bak` — stale unmanaged backup (old Iosevka/gruvbox config); ignore.

## Fonts

The font stack (JetBrainsMono NF **Thin** regular, **Light** as "bold") is deliberate — it is the reference look that wezterm's font config was once matched against. Do not change weights or family without being asked.

## Remote control / opacity toggle

On Linux, `kitty.conf` sets `allow_remote_control socket-only` with a per-process socket at `$XDG_RUNTIME_DIR/kitty-{kitty_pid}.sock`. Consumer: `~/.config/niri/scripts/toggle_opacity.sh` (`Mod+Shift+T`), which sets all running kitties opaque/translucent in lockstep with wezterm's state-file toggle.

Gotchas:
- `listen_on` cannot be enabled by config reload (`ctrl+shift+f5`/SIGUSR1) — kitty must be fully restarted for the socket to appear.
- `kitten @ set-background-opacity default` silently means opacity **0** (fully transparent) as of kitty 0.47 — always send explicit numeric values.
