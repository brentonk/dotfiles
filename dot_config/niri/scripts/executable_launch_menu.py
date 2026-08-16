#!/usr/bin/env python3
"""Merged launcher for niri: applications + documents + Obsidian notes.

Bound to Mod+Space. Feeds one list into `fuzzel --dmenu` and dispatches the
selection. Deliberately bounded to three kinds of thing -- Spotlight-shaped,
not an everything-search. Mod+Z (full-$HOME PDF sweep) and Mod+B (bibliography)
remain the narrow escape hatches.

Rows are three tab-separated columns, the same trick refmenu.sh uses:

    payload <TAB> display <TAB> keywords \0icon\x1f<icon-name>

fuzzel shows column 2, matches columns 2..3, and returns column 1. The rofi
icon protocol composes with those flags (verified against fuzzel 1.14.1: the
icon marker is a NUL-terminated suffix, so every column operation happens on
the icon-stripped text), which is how entries keep real themed icons.

Ranking is fuzzel's own: relevance first, with the `--cache` frecency counter
as a tiebreaker. On an empty query every other key ties, so the list opens on
your most-used entries. That cache is keyed on the *display* column, so column
2 must stay stable across runs.

Stdlib only: `uv` is never on the hot path. The one slow dependency is the
bibtexparser run that turns references.bib into reference rows, and that is
cached against the bib file's mtime.

Subcommands:
    --print-rows          write the TSV to stdout, no UI (for testing)
    --dispatch <payload>  act on one payload directly (for testing)
    [fuzzel args...]      default; extra args pass through to fuzzel
"""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

HOME = Path.home()

# --- locations ---------------------------------------------------------------

IGNORE_FILE = HOME / ".config/niri/launcher-ignore"
XDG_CACHE = Path(os.environ.get("XDG_CACHE_HOME", HOME / ".cache"))
CACHE_DIR = XDG_CACHE / "niri-launcher"
REFS_CACHE = CACHE_DIR / "refs.tsv"
MRU_CACHE = CACHE_DIR / "mru"
FUZZEL_APP_CACHE = XDG_CACHE / "fuzzel"

REFERENCES_DIR = HOME / "Dropbox/references"
REFMENU = REFERENCES_DIR / "refmenu.sh"
BIBFILE = REFERENCES_DIR / "references.bib"
LIBRARY = REFERENCES_DIR / "library"

VAULT = HOME / "obsidian"
DOC_ROOTS = [HOME / "Dropbox", HOME / "Downloads", HOME / "Documents"]


def app_dirs() -> list[Path]:
    """Application directories, highest precedence first (XDG spec order)."""
    data_home = os.environ.get("XDG_DATA_HOME") or str(HOME / ".local/share")
    data_dirs = os.environ.get("XDG_DATA_DIRS") or "/usr/local/share:/usr/share"
    return [Path(d) / "applications" for d in [data_home, *data_dirs.split(":")] if d]


APP_DIRS = app_dirs()

# --- appearance --------------------------------------------------------------
# House style, matching the other fuzzel call sites in config.kdl.
FUZZEL_STYLE = [
    "--font=Iosevka Nerd Font:size=12",
    "--width=100",
    "--lines=16",
    "--border-width=2",
    "--prompt=",
    "--placeholder=app, document, or note",
]

# Only applications get themed icons, and that is a hard constraint rather than
# a taste call: fuzzel resolves the icon name per *row*, not per unique name, so
# a corpus of ~8,800 document rows all asking for "application-pdf" silently
# renders no icons at all. Measured: 2,000 icon rows fine, 9,400 fine only when
# the marker is confined to the ~48 application rows. Documents and notes get
# Nerd Font glyphs in the display text instead, which costs zero lookups and so
# stays correct however wide launcher-ignore is opened up.
ICON_APP = "application-x-executable"

GLYPH_REF = ""  # book
GLYPH_DOC = ""  # file-pdf
GLYPH_NOTE = ""  # file-text

UNIT = "\x1f"  # rofi icon-protocol separator
FIELD_CODES = re.compile(r"%[fFuUickdDnNvm]")


def clean(text: str) -> str:
    """Strip characters that would corrupt the tab-separated row format."""
    return text.replace("\t", " ").replace("\n", " ").replace("\0", "").strip()


# --- applications ------------------------------------------------------------


def parse_desktop(path: Path) -> dict[str, str] | None:
    """Minimal [Desktop Entry] reader.

    Hand-rolled rather than configparser: desktop files routinely contain
    duplicate keys and `%` field codes, which configparser's interpolation and
    strict mode both reject, and desktop keys are case-sensitive.
    """
    try:
        text = path.read_text(errors="replace")
    except OSError:
        return None

    entry: dict[str, str] = {}
    in_section = False
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("["):
            if in_section:
                break  # past [Desktop Entry] into a [Desktop Action ...] group
            in_section = line == "[Desktop Entry]"
            continue
        if not in_section or not line or line.startswith("#"):
            continue
        key, sep, value = line.partition("=")
        if sep and "[" not in key:  # skip localized keys such as Name[de]
            entry.setdefault(key.strip(), value.strip())
    return entry or None


def load_apps() -> dict[str, dict[str, str]]:
    """Visible desktop entries, keyed by desktop-file id, first directory wins."""
    apps: dict[str, dict[str, str]] = {}
    for directory in APP_DIRS:
        if not directory.is_dir():
            continue
        for path in sorted(directory.glob("*.desktop")):
            if path.name in apps:
                continue  # a higher-precedence directory already shadowed it
            entry = parse_desktop(path)
            if not entry:
                continue
            if entry.get("Type", "Application") != "Application":
                continue
            if entry.get("NoDisplay", "").lower() == "true":
                continue
            if entry.get("Hidden", "").lower() == "true":
                continue
            try_exec = entry.get("TryExec", "")
            if try_exec and not shutil.which(try_exec):
                continue
            entry["_path"] = str(path)
            apps[path.name] = entry
    return apps


def app_rows(apps: dict[str, dict[str, str]]) -> list[tuple[str, str, str, str]]:
    rows = []
    for desktop_id, entry in apps.items():
        name = clean(entry.get("Name", "")) or Path(desktop_id).stem
        keywords = clean(
            "@app "
            + " ".join(
                filter(
                    None,
                    (
                        entry.get("GenericName", ""),
                        entry.get("Comment", ""),
                        entry.get("Keywords", "").replace(";", " "),
                        entry.get("Exec", ""),
                    ),
                )
            )
        )
        icon = clean(entry.get("Icon", "")) or ICON_APP
        if "/" not in icon:
            icon = f"{icon},{ICON_APP}"
        rows.append((f"A:{desktop_id}", name, keywords, icon))

    rows.sort(key=lambda r: r[1].lower())
    return rows


# --- references --------------------------------------------------------------


def refresh_refs_cache() -> None:
    """Regenerate the bib rows via refmenu.sh, which owns the parser.

    Missing cache: build synchronously (~60ms, once). Stale cache: serve the
    stale copy now and rebuild in the background, so a freshly rebuilt
    references.bib never costs you a slow Mod+Space.
    """
    if not (REFMENU.is_file() and BIBFILE.is_file()):
        return
    if REFS_CACHE.exists():
        if REFS_CACHE.stat().st_mtime >= BIBFILE.stat().st_mtime:
            return
        detach(
            [
                "sh",
                "-c",
                f'"$1" --print-rows > "$2.tmp" && mv "$2.tmp" "$2"',
                "sh",
                str(REFMENU),
                str(REFS_CACHE),
            ]
        )
        return

    try:
        result = subprocess.run(
            [str(REFMENU), "--print-rows"], capture_output=True, text=True, timeout=60
        )
    except (OSError, subprocess.SubprocessError):
        return
    if result.returncode == 0 and result.stdout.strip():
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        tmp = REFS_CACHE.with_suffix(".tmp")
        tmp.write_text(result.stdout)
        tmp.replace(REFS_CACHE)


def ref_rows() -> list[tuple[str, str, str, str]]:
    refresh_refs_cache()
    if not REFS_CACHE.exists():
        return []

    rows = []
    for line in REFS_CACHE.read_text(errors="replace").splitlines():
        citekey, _, display = line.partition("\t")
        if not citekey or not display:
            continue
        pdf = f"{LIBRARY}/{citekey}.pdf"
        if not os.path.isfile(pdf):
            continue  # nothing to open; Mod+B still surfaces these
        rows.append(
            (f"P:{pdf}", f"{GLYPH_REF}  {clean(display)}", f"@doc @ref {citekey}", "")
        )
    return rows


# --- documents and notes -----------------------------------------------------
#
# These loops run over ~9k paths, so they work on plain strings: constructing a
# Path per entry costs more than everything else in the script combined.


def fd_find(extension: str, roots: list[Path], use_ignore_file: bool) -> list[str]:
    existing = [str(r) for r in roots if r.exists()]
    if not existing:
        return []
    cmd = ["fd", "--type", "f", "--extension", extension, "--print0"]
    if use_ignore_file and IGNORE_FILE.is_file():
        cmd += ["--ignore-file", str(IGNORE_FILE)]
    cmd += [".", *existing]
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.SubprocessError):
        return []
    return [p for p in result.stdout.split("\0") if p]


def doc_rows(ref_paths: set[str]) -> list[tuple[str, str, str, str]]:
    home_prefix = f"{HOME}/"
    rows = []
    for path in fd_find("pdf", DOC_ROOTS, use_ignore_file=True):
        # Skip only the exact papers already listed as bibliography rows, not
        # the whole library: a dozen appendices and un-cited PDFs live there
        # without a bib entry, and dropping the directory wholesale hides them.
        if path in ref_paths:
            continue
        parent, _, filename = path.rpartition("/")
        if filename.endswith(".pdf"):
            filename = filename[:-4]
        if parent.startswith(home_prefix):
            parent = parent[len(home_prefix) :]
        # The parent is in the display, not just the keywords: with thousands of
        # documents, bare stems collide both visually and as --cache keys.
        rows.append(
            (
                f"P:{path}",
                f"{GLYPH_DOC}  {clean(filename)}  ·  {clean(parent)}",
                "@doc",
                "",
            )
        )
    return rows


def note_rows() -> list[tuple[str, str, str, str]]:
    prefix = f"{VAULT}/"
    rows = []
    for path in fd_find("md", [VAULT], use_ignore_file=False):
        if not path.startswith(prefix):
            continue
        relative = path[len(prefix) :]
        display = relative[:-3] if relative.endswith(".md") else relative
        rows.append((f"N:{relative}", f"{GLYPH_NOTE}  {clean(display)}", "@note", ""))

    rows.sort(key=lambda r: r[1].lower())
    return rows


# --- frecency seeding --------------------------------------------------------


def seed_mru(apps: dict[str, dict[str, str]]) -> None:
    """Translate fuzzel's app-mode cache into a dmenu-mode cache, once.

    fuzzel keys the app cache by desktop-file id but the dmenu cache by display
    string, so this remaps `vivaldi-stable.desktop|161` to `Vivaldi|161`. After
    this, fuzzel owns the file -- we never write it again.
    """
    if MRU_CACHE.exists() or not FUZZEL_APP_CACHE.exists():
        return

    lines = []
    for line in FUZZEL_APP_CACHE.read_text(errors="replace").splitlines():
        desktop_id, sep, count = line.rpartition("|")
        if not sep or desktop_id not in apps:
            continue
        name = clean(apps[desktop_id].get("Name", ""))
        if name and count.isdigit():
            lines.append(f"{name}|{count}\n")

    if lines:
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        MRU_CACHE.write_text("".join(lines))


# --- assembly and dispatch ---------------------------------------------------


def build_rows(apps: dict[str, dict[str, str]]) -> list[tuple[str, str, str, str]]:
    # Emission order only decides ties (fuzzel sorts by relevance, then by the
    # frecency counter), but it keeps applications ahead of documents when
    # nothing else distinguishes them.
    refs = ref_rows()
    ref_paths = {payload[2:] for payload, _, _, _ in refs}
    return app_rows(apps) + refs + note_rows() + doc_rows(ref_paths)


def render(rows: list[tuple[str, str, str, str]]) -> str:
    return "".join(
        f"{payload}\t{display}\t{keywords}\0icon{UNIT}{icon}\n"
        if icon
        else f"{payload}\t{display}\t{keywords}\n"
        for payload, display, keywords, icon in rows
    )


def detach(cmd: list[str]) -> None:
    """Launch and survive this process exiting.

    Note: `detach` (the binary refmenu.sh prefers) is not installed here, so
    refmenu.sh has always been taking its setsid fallback. Use setsid directly.
    """
    try:
        subprocess.Popen(
            ["setsid", "-f", *cmd],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except OSError:
        pass


def launch_app(desktop_id: str, apps: dict[str, dict[str, str]]) -> int:
    entry = apps.get(desktop_id)
    if entry is None:
        return 1

    if entry.get("Terminal", "").lower() == "true":
        # gio launch would try GLib's hardcoded terminal list (gnome-terminal,
        # konsole, xterm, ...), none of which are installed here -- so terminal
        # entries such as htop/nvim/ranger would silently fail. Use kitty, the
        # primary terminal, directly.
        command = FIELD_CODES.sub("", entry.get("Exec", "")).replace("%%", "%").strip()
        if not command:
            return 1
        detach(["kitty", "sh", "-c", command])
    else:
        detach(["gio", "launch", entry["_path"]])
    return 0


def dispatch(payload: str, apps: dict[str, dict[str, str]]) -> int:
    kind, sep, target = payload.partition(":")
    if not sep:
        return 0  # Shift+Return returns the raw query; ignore it

    if kind == "A":
        return launch_app(target, apps)
    if kind == "P":
        detach(["zathura", target])
        return 0
    if kind == "N":
        # The obsidian:// scheme handler starts Obsidian if it is closed and
        # opens the note in the running instance if it is not; the `obsidian`
        # CLI only ever talks to a live instance.
        from urllib.parse import quote

        uri = f"obsidian://open?vault={quote(VAULT.name)}&file={quote(target)}"
        detach(["xdg-open", uri])
        return 0
    return 0


def main(argv: list[str]) -> int:
    apps = load_apps()

    if argv and argv[0] == "--dispatch":
        return dispatch(argv[1], apps) if len(argv) > 1 else 1

    CACHE_DIR.mkdir(parents=True, exist_ok=True)
    rows = build_rows(apps)

    if argv and argv[0] == "--print-rows":
        sys.stdout.write("".join(f"{p}\t{d}\t{k}\n" for p, d, k, _ in rows))
        return 0

    if not rows:
        return 1

    seed_mru(apps)

    result = subprocess.run(
        [
            "fuzzel",
            "--dmenu",
            "--with-nth=2",
            "--match-nth={2..}",
            "--accept-nth=1",
            # Tokenised substring matching: verified to split the query on
            # whitespace and match tokens out of order, so "kahneman prospect"
            # and the @app/@doc/@ref/@note sigils both work.
            "--match-mode=exact",
            "--only-match",
            "--counter",
            f"--cache={MRU_CACHE}",
            *FUZZEL_STYLE,
            *argv,
        ],
        input=render(rows),
        capture_output=True,
        text=True,
    )

    payload = result.stdout.strip()
    if result.returncode != 0 or not payload:
        return 0  # dismissed
    return dispatch(payload, apps)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
