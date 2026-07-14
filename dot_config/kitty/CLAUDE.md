# Kitty Configuration

Primary terminal as of July 2026 (`Mod+Return` in niri; wezterm is secondary).

## Files

- `kitty.conf` — rendered from a chezmoi **template** (`dot_config/kitty/kitty.conf.tmpl`). **Edit the template, never the rendered file.** Templating is OS-level only (the Linux-gated remote-control block); host-specific font/size/opacity deviations do NOT belong in the template — they go in that host's `kitty.local.conf`.
- `current-theme.conf` — chezmoi-managed (plain). Flexoki Dark, from the mbadolato/iTerm2-Color-Schemes kitty port — the same collection wezterm's built-in `flexoki-dark` derives from, so the two terminals' palettes match exactly. The `BEGIN_KITTY_THEME`/`END_KITTY_THEME` markers in `kitty.conf` are managed by `kitten themes`; if that tool is ever re-run, re-add both files to chezmoi.
- `kitty.local.conf` — per-host overrides (font size, opacity, anything), loaded **last** via `globinclude` so it wins over everything. NOT chezmoi-managed (listed in `.chezmoiignore`) — never add it. Mirrors wezterm's `*.local` convention.

## Per-host values (seed data for kitty.local.conf)

The template's defaults are JetBrainsMono NF Thin/Light, `font_size 11.5`, `background_opacity 0.95`. Known deviations, formerly encoded as hostname conditionals in the template — when setting up (or fixing) a host, recreate its `kitty.local.conf` from this table:

| Host | kitty.local.conf contents |
|------|---------------------------|
| `milchick` (Arch) | `background_opacity 0.97` (matches wezterm's `opacity.local`) |
| `trebek` (Arch) | `font_size 10` |
| `ASLNX-24CXCB4` (Ubuntu) | `background_opacity 0.92` |
| `AS0374CD6G` (macOS) | `font_family JetBrainsMono Nerd Font Mono`, `italic_font auto`, `bold_font auto`, `bold_italic_font auto`, `font_size 14`, `background_opacity 0.97` |

The macOS host needs the three `auto` lines because the shared defaults name Linux-only font variants; `auto` resets them so kitty derives italic/bold from `font_family` again.
- `kitty.conf.bak` — stale unmanaged backup (old Iosevka/gruvbox config); ignore.

## Fonts

The font stack (JetBrainsMono NF **Thin** regular, **Light** as "bold") is deliberate — it is the reference look that wezterm's font config was once matched against. Do not change weights or family without being asked.

## Remote control / opacity toggle

On Linux, `kitty.conf` sets `allow_remote_control socket-only` with a per-process socket at `$XDG_RUNTIME_DIR/kitty-{kitty_pid}.sock`. Consumer: `~/.config/niri/scripts/toggle_opacity.sh` (`Mod+Shift+T`), which sets all running kitties opaque/translucent in lockstep with wezterm's state-file toggle.

Gotchas:
- `listen_on` cannot be enabled by config reload (`ctrl+shift+f5`/SIGUSR1) — kitty must be fully restarted for the socket to appear.
- `kitten @ set-background-opacity default` silently means opacity **0** (fully transparent) as of kitty 0.47 — always send explicit numeric values.
