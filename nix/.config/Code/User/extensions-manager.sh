#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#jq --command bash
# shellcheck shell=bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

DESIRED=$(nix eval --json -f "$DIR/extensions.nix" | jq -r '.[]' | tr '[:upper:]' '[:lower:]' | sort)
INSTALLED=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort)

echo "[+] To install:"
comm -23 <(echo "$DESIRED") <(echo "$INSTALLED") | sed 's/^/  /'

echo "[-] To remove:"
comm -13 <(echo "$DESIRED") <(echo "$INSTALLED") | sed 's/^/  /'
