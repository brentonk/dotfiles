#!/usr/bin/env python3
# kitty geninclude generator: emits an include for the active theme collection.
# The collection name lives in ~/.config/theme.local (NOT chezmoi-managed);
# missing file or unknown name falls back to flexoki-dark. nvim reads the same
# file in lua/plugins/COLORS.lua -- keep the parsing rules in sync.
import os

KITTY_DIR = os.path.dirname(os.path.abspath(__file__))
COLLECTIONS = os.path.join(KITTY_DIR, "collections")
NAME_FILE = os.path.join(os.path.dirname(KITTY_DIR), "theme.local")
DEFAULT = "flexoki-dark"


def collection_name():
    try:
        with open(NAME_FILE) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    return line.split()[0]
    except OSError:
        pass
    return DEFAULT


name = collection_name()
path = os.path.join(COLLECTIONS, name + ".conf")
if not os.path.isfile(path):
    path = os.path.join(COLLECTIONS, DEFAULT + ".conf")
print("include", path)
