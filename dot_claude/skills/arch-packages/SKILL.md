---
name: arch-packages
description: Analyze config files and installed packages to generate a categorized Arch Linux package install list. Discovers packages from config directories, dotfiles, shell functions, compositor bindings, and editor plugins. Validates against official repos and AUR. Writes a chezmoi-managed install list to ~/.config/arch-packages.txt.
---

# Arch Packages Discovery Workflow

Generate a comprehensive, categorized list of application-layer Arch Linux packages needed to reproduce this system's setup.

## Scope

- Application-layer packages only (no base, kernels, firmware, bootloader, networking stack)
- Fonts ARE included
- Packages managed outside pacman (pip, npm, Mason) are noted in comments but excluded from the install list

## Step 1: Discovery

Run the discovery script to scan configs and query pacman:

```bash
~/.claude/skills/arch-packages/scripts/discover-packages.sh
```

This outputs structured sections:
- **MAPPED CONFIG DIRS** — config directories matched to known packages
- **UNMAPPED CONFIG DIRS** — config directories marked `__UNKNOWN__` for you to resolve
- **HOME DOTFILE PACKAGES** — packages inferred from home directory dotfiles
- **CONFIG FILE REFERENCES** — tools referenced in fish functions, sway config, waybar, etc.
- **INSTALLED PACKAGES** — `pacman -Qe` native packages (ground truth)
- **INSTALLED AUR PACKAGES** — `pacman -Qm` foreign/AUR packages
- **NON-PACMAN TOOLS** — tools managed by pip, Mason, npm, etc.

## Step 2: Validation

For any package names you're uncertain about, validate them:

```bash
~/.claude/skills/arch-packages/scripts/validate-packages.sh pkg1 pkg2 pkg3
```

Or pipe a list:

```bash
echo "neovim bat eza" | ~/.claude/skills/arch-packages/scripts/validate-packages.sh
```

This checks each package against official repos and AUR via `yay -Si` and reports:
- `OK <pkg> (<repo>)` — package found
- `NOTFOUND <pkg>` — package doesn't exist

## Step 3: Analysis (your judgment)

After running both scripts, apply your judgment:

1. **Resolve `__UNKNOWN__` entries** — For each unmapped config dir, search with `yay -Ss <name>` to find the correct package. If no package exists (it's a config-only dir), skip it.

2. **Cross-reference** — Compare discovered packages against the `pacman -Qe` output:
   - Packages in `pacman -Qe` but NOT found in configs may still be needed (ask the user)
   - Packages in configs but NOT in `pacman -Qe` should still be included (they're needed)

3. **Filter out base/system packages** from `pacman -Qe` — Skip: base, base-devel, linux, linux-firmware, linux-headers, grub, efibootmgr, amd-ucode, intel-ucode, networkmanager, dhcpcd, iwd, wpa_supplicant, and similar low-level packages

4. **Categorize** — Group packages into categories:
   - Shells
   - Terminal Emulators
   - Window Manager / Compositor
   - Status Bar / Desktop
   - Editors
   - Developer Tools
   - File Managers
   - Document Viewers
   - Web Browsers
   - Media / Audio
   - Fonts
   - System Utilities
   - AUR Packages
   - (add more categories as needed)

5. **Validate the final list** — Run all candidate packages through `validate-packages.sh` to confirm they all resolve

## Step 4: Output

Write the categorized package list to `~/.config/arch-packages.txt`:

```
# Generated on <hostname> at <YYYY-MM-DD HH:MM>

# Category Name
package1
package2

# Another Category
package3
```

Rules:
- First line must be a comment with the hostname (`hostname`) and timestamp (`date '+%Y-%m-%d %H:%M'`)
- Comment lines (`#`) are category headers
- One package per line, no version numbers
- Blank lines between categories for readability
- Add `# Non-pacman tools (not included in install list)` section at the end as comments only

The file should be usable with:
```bash
grep -v '^#' ~/.config/arch-packages.txt | grep -v '^$' | yay -S --needed -
```

## Step 5: Chezmoi Integration

After writing the file, add it to chezmoi:

```bash
chezmoi add ~/.config/arch-packages.txt
```

Then verify:
```bash
chezmoi diff
```
