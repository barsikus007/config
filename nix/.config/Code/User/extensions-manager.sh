#!/usr/bin/env --split-string nix shell nixpkgs#bash nixpkgs#jq --command bash
# shellcheck shell=bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

EXTENSIONS=$(nix eval --json -f "$DIR/extensions.nix")

DESIRED=$(echo "$EXTENSIONS" | jq -r '.all[]' | tr '[:upper:]' '[:lower:]' | sort)
IN_NIXPKGS=$(echo "$EXTENSIONS" | jq -r '.inNixpkgs[]' | tr '[:upper:]' '[:lower:]' | sort)
INSTALLED=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort)

echo "[+] To install:"
comm -23 <(echo "$DESIRED") <(echo "$INSTALLED") | sed 's/^/  /'

echo "[-] To remove:"
comm -13 <(echo "$DESIRED") <(echo "$INSTALLED") | sed 's/^/  /'

# echo "[~] In nixpkgs (available via pkgs.vscode-extensions):"
# comm -12 <(echo "$DESIRED") <(echo "$IN_NIXPKGS") | sed 's/^/  /'

echo "[!] Not in nixpkgs:"
comm -23 <(echo "$DESIRED") <(echo "$IN_NIXPKGS") | sed 's/^/  /'
