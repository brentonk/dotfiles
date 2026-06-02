# Chezmoi Configuration Directory

Many files in this directory and its subdirectories are managed by chezmoi.

## Before Editing Files

Check if a file is managed by chezmoi:
```bash
chezmoi source-path <file>
```

If the file is managed by a **template** (source file ends in `.tmpl`), do not edit the target file directly. Instead, edit the template in the chezmoi source directory.

## After Editing

Run `/chezmoi-sync` after:
- Editing any chezmoi-managed file
- Creating new files in directories where other files are managed by chezmoi

## Before Pushing to GitHub

Always check with me before pushing chezmoi changes to GitHub — **even in auto/autonomous mode**. Staging the changes (`chezmoi re-add`/`chezmoi add`) and committing locally is fine, but pause and ask for explicit confirmation before `git push`. I often iterate rapidly, and I don't want a string of pushed commits representing states that were immediately discarded.
