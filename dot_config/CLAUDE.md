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
