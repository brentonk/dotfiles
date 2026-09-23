# Prose in Brenton's documents is Brenton's

Brenton's name goes on his papers, lecture notes, and slides, so the prose in them has to be his. When working on such a document:

- Do not write new prose, including short elements: figure captions, slide titles, section headings, abstract text, bullet points.
- Do not silently revise existing prose. If you spot a typo or an error, leave it and note it in your report when you finish the task. Ask before changing anything.
- Where text is needed, insert `TODO(BJK): <brief description of what needs done>` and mention it when you report back. If a field must be non-empty to compile or to check layout, use that same string as the placeholder.
- If asked to help with the writing, you can offer notes, an outline, or alternatives to react to. Draft finished prose only on explicit request.

This applies to: papers, lecture notes, slides, referee reports, memos, grant applications, letters, and anything else intended for public circulation or presentation under Brenton's name.

This does NOT apply to: code comments and docstrings, commit messages, README files for code repositories, CLAUDE.md and other config, test fixtures, or documents where Brenton is not the author (e.g. "read this code and write a Markdown explainer" — just write it).

# Document Source Formatting

## One Sentence Per Line

In LaTeX (`.tex`), Typst (`.typ`), and Quarto (`.qmd`) source files, write exactly one sentence per line: break the line at the end of each sentence and never hard-wrap within a sentence.

This convention does NOT apply to ordinary Markdown (`.md`) files, which are sometimes distributed as-is rather than compiled to PDF/HTML.

## Obsidian

When editing files in my Obsidian vault (`~/obsidian`) or via the CLI (`obsidian` shell command), follow Obsidian Markdown idiosyncracies, including:
- Empty line before a headline, but not after
- Indent width = 4
- Unicode dashes (— instead of ---, – instead of --)

Obsidian files are ordinary Markdown, so do not use the one-sentence-per-line convention. There should still be no hard wrapping.

## Quarto Preview

I often have `quarto preview` running on the Quarto document you're editing. Before running `quarto render` yourself, check for a preview process watching that file (e.g., `pgrep -af "[q]uarto preview"`; the brackets keep the pattern from matching the shell running the check). If there is one, don't render: the preview re-renders on every save, and a concurrent render collides with it over the knitr cache and intermediate files (symptoms: "cannot open the connection", missing cache objects, a render that fails once and then succeeds). Instead, save your edit, wait until the output file is newer than the source, and inspect that output.

# Python Project Guidelines

## Package Manager: uv

Always use `uv` for Python project management instead of pip, pip-tools, poetry, or other tools.

### Project Setup
- Initialize new projects with `uv init`
- Use `uv venv` to create virtual environments
- Use `uv sync` to install dependencies from pyproject.toml/uv.lock

### Dependency Management
- Add dependencies with `uv add <package>`
- Add dev dependencies with `uv add --dev <package>`
- Remove dependencies with `uv remove <package>`
- Update dependencies with `uv lock --upgrade` or `uv lock --upgrade-package <package>`

### Running Code
- Run scripts with `uv run python <script.py>`
- Run tools with `uv run <tool>` (e.g., `uv run pytest`, `uv run ruff`)
- Use `uv tool run` (or `uvx`) for one-off tool execution without installing

### Pyright Configuration
- If a Python project has a `.venv` but no `pyrightconfig.json`, create one so pyright resolves dependencies from the venv:
  ```json
  { "venvPath": ".", "venv": ".venv" }
  ```
- Place it in the same directory as the `.venv`

### Key Principles
- Never use `pip install` directly; use `uv add` or `uv pip install` if raw pip interface needed
- Prefer `uv run` to activate environments implicitly rather than manual activation
- Commit both `pyproject.toml` and `uv.lock` to version control

# Software Installation

## Arch Linux
- You may suggest software packages from the AUR, but never attempt to install them yourself
- `paru` is the AUR helper of choice---let me run it myself in a separate terminal so I can validate PKGBUILD
