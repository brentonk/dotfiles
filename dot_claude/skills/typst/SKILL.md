---
name: typst
description: Use this skill whenever working with Typst documents, templates, or code — including writing .typ files, using Typst packages, debugging Typst compilation errors, or converting LaTeX to Typst. Trigger on any mention of "typst", ".typ files", Typst packages, or Typst-specific syntax. Also trigger when the user asks to create academic papers, slides, or documents and Typst is their preferred toolchain. IMPORTANT — Typst's API changes frequently and your training data is likely stale. This skill exists to prevent you from hallucinating function signatures, package names, and syntax. Follow it closely.
---

# Typst Skill

You are working with Typst, a modern typesetting system. **Your training data about Typst is unreliable.** Typst is young and evolving fast — function signatures, package names, and even core syntax have changed across versions. You MUST verify before writing.

## Rule 1: Never Guess — Always Verify

Before using ANY Typst function, package, or syntax you are not 100% certain about, look it up with WebFetch. "Pretty sure" is not certain. The cost of checking is seconds; the cost of hallucinating is the user debugging your garbage.

### Base Typst functions

Documentation lives at `https://typst.app/docs/`. The reference follows a predictable URL structure:

```
https://typst.app/docs/reference/{category}/{function}/
```

Common categories: `math`, `text`, `layout`, `model`, `visualize`, `foundations`, `data-loading`.

**Before using a function, fetch its docs page.** For example, before using `frac()` in math mode, fetch `https://typst.app/docs/reference/math/frac/` and use the documented parameter names. Do not guess parameter names from LaTeX analogy.

### Packages

The Typst package registry is at `https://typst.app/universe/`. Every published package has a page at:

```
https://typst.app/universe/package/{package-name}
```

**Before importing any package:**
1. Verify it exists by fetching its universe page
2. Check the current version number
3. Read the documentation (usually on the universe page or linked GitHub README)
4. Use the correct import syntax: `#import "@preview/{name}:{version}": {items}`

Never invent a package name. Never guess a version number.

### When fetching fails

If WebFetch is unavailable or the page can't be retrieved, say so explicitly. Do NOT fall back to guessing. Tell the user what you tried to look up and ask them to verify or paste the relevant docs.

## Rule 2: Compile and Check

After writing or modifying any `.typ` file, run:

```bash
typst compile <file>.typ
```

If it errors, fix the errors before presenting the result. Do not hand the user code you haven't tried to compile.

If `typst` is not installed, tell the user and ask them to install it (e.g. `pacman -S typst` on Arch, or see https://github.com/typst/typst for other platforms). Do not silently skip the compile step.

## Rule 3: Typst Is Not LaTeX

Your LaTeX intuitions will mislead you. Key differences:

**Modes and syntax:**
- Content mode is the default. Code expressions start with `#` in content mode.
- `[]` is a content block, `{}` is a code block. They are not interchangeable.
- Strings use `"double quotes"`, not single quotes.

**Set and show rules:**
- `#set` configures defaults: `#set text(size: 12pt)`
- `#show` transforms elements: `#show heading: set text(blue)`
- These are NOT like LaTeX `\renewcommand`. Read the docs if unsure about scoping.

**Math mode:**
- Entered with `$...$` (inline) or `$ ... $` (with spaces = display).
- Function names differ from LaTeX. Examples of traps:
  - `arrow(x)` not `\vec{x}`
  - `frac(a, b)` not `\frac{a}{b}` — and check the actual parameter names
  - Named symbols differ: check `https://typst.app/docs/reference/symbols/sym/`
- **When in doubt about ANY math function, fetch its docs page.**

**Imports:**
- Packages: `#import "@preview/package-name:0.1.0": func1, func2`
- Local files: `#import "other.typ": func1`
- There is no `\usepackage`.

## Rule 4: Known Hallucination Traps

These are areas where LLMs consistently get Typst wrong. Be extra cautious:

- **`frac()` parameters** — look them up, do not guess
- **Table syntax** — Typst tables use `table(columns: ..., ..cells..)`, not LaTeX tabular syntax
- **Bibliography** — `#bibliography("refs.bib")` works but citation syntax and CSL support have evolved; check docs
- **Page setup** — `#set page(...)` not `\geometry{}`; parameter names are Typst-specific
- **Figure/image** — `#figure(image("path"), caption: [...])`, but check current parameter names
- **Theorem environments** — no built-in equivalent; the user's preferred package is `theorion`. Verify its current version and API on the registry before use.

## Quarto Integration

If the user is using Quarto with `format: typst`, note:
- Quarto has its own Typst template system
- Raw Typst blocks in Quarto use ````{=typst}` fencing
- Some Typst features may behave differently inside Quarto's pipeline
- Check Quarto's Typst docs at `https://quarto.org/docs/output-formats/typst.html` if relevant

## Summary Checklist

Before delivering any Typst code:
1. Did I verify every function signature against the docs?
2. Did I verify every package name and version against the registry?
3. Did I compile the code and confirm it works?
4. Am I using Typst idioms, not LaTeX idioms with Typst syntax?
