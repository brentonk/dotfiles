# Document Source Formatting

## One Sentence Per Line

In LaTeX (`.tex`), Typst (`.typ`), and Quarto (`.qmd`) source files, write exactly one sentence per line: break the line at the end of each sentence and never hard-wrap within a sentence.

This convention does NOT apply to ordinary Markdown (`.md`) files, which are sometimes distributed as-is rather than compiled to PDF/HTML.

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
