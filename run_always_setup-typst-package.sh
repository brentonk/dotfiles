#!/bin/bash
# Create local Typst package symlink for bjk-academic if the repo exists

repo="$HOME/Dropbox/github/bjk-typst"

case "$(uname -s)" in
    Darwin)
        pkg_root="$HOME/Library/Application Support/typst/packages"
        ;;
    *)
        pkg_root="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages"
        ;;
esac
pkg_dir="$pkg_root/local/bjk-academic/0.1.0"

if [ -L "$pkg_dir" ]; then
    echo "bjk-academic symlink already exists, skipping"
    exit 0
fi

if [ ! -d "$repo" ]; then
    echo "bjk-typst repo not found at $repo (Dropbox may not have synced yet), skipping"
    exit 0
fi

mkdir -p "$(dirname "$pkg_dir")"
ln -s "$repo" "$pkg_dir"
echo "Created bjk-academic symlink: $pkg_dir -> $repo"
