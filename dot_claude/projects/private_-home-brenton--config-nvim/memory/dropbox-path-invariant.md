---
name: dropbox-path-invariant
description: "~/Dropbox is a guaranteed-stable path on all of the user's machines (Linux and mac); no need to handle macOS CloudStorage relocation"
metadata: 
  node_type: memory
  type: user
  originSessionId: a2e39e5f-b3da-4aee-b411-038091ada7d6
---

The user has `~/Dropbox/...` hardcoded in many places across their configs and would move it back or symlink it if Dropbox ever relocated it (e.g. macOS `~/Library/CloudStorage`).

**Why:** Treating `~/Dropbox` as a stable invariant avoids over-engineering path checks (realpath resolution, symlink handling) for a case the user has guaranteed won't matter.

**How to apply:** When writing config/code that references Dropbox paths, use `~/Dropbox/...` with simple tilde expansion and prefix checks; don't add macOS CloudStorage fallbacks or symlink-resolution logic.
