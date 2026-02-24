#!/usr/bin/env bash
# validate-packages.sh — Validate candidate package names against repos/AUR
# Usage: validate-packages.sh pkg1 pkg2 pkg3 ...
#    or: echo "pkg1 pkg2" | validate-packages.sh
# Requires: yay
set -uo pipefail

validate_pkg() {
  local pkg="$1"
  # Skip comments and empty lines
  [[ -z "$pkg" || "$pkg" == \#* ]] && return 0

  local info
  if info=$(yay -Si "$pkg" 2>&1); then
    local repo
    repo=$(echo "$info" | grep -m1 '^Repository' | awk '{print $3}')
    echo "OK  $pkg  ($repo)"
  else
    echo "NOTFOUND  $pkg"
  fi
}

# Read packages from args or stdin
pkgs=()
if [[ $# -gt 0 ]]; then
  pkgs=("$@")
else
  while IFS= read -r line; do
    # Strip comments (inline and full-line) and whitespace
    line="${line%%#*}"
    line="${line// /}"
    [[ -n "$line" ]] && pkgs+=("$line")
  done
fi

if [[ ${#pkgs[@]} -eq 0 ]]; then
  echo "Usage: $0 pkg1 pkg2 ..." >&2
  echo "   or: echo 'pkg1 pkg2' | $0" >&2
  exit 1
fi

echo "=== PACKAGE VALIDATION ==="
echo "# Validating ${#pkgs[@]} packages against repos and AUR..."
echo ""

ok_count=0
fail_count=0
for pkg in "${pkgs[@]}"; do
  result=$(validate_pkg "$pkg")
  if [[ -n "$result" ]]; then
    echo "$result"
    if [[ "$result" == OK* ]]; then
      ((ok_count++))
    elif [[ "$result" == NOTFOUND* ]]; then
      ((fail_count++))
    fi
  fi
done

echo ""
echo "=== SUMMARY ==="
echo "Valid: $ok_count"
echo "Not found: $fail_count"
