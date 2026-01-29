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

### Key Principles
- Never use `pip install` directly; use `uv add` or `uv pip install` if raw pip interface needed
- Prefer `uv run` to activate environments implicitly rather than manual activation
- Commit both `pyproject.toml` and `uv.lock` to version control
