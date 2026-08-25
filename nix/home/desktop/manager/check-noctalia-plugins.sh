#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#curl nixpkgs#yq-go --command bash
# shellcheck shell=bash
set -euo pipefail

#? https://noctalia.dev/plugins
#? https://github.com/noctalia-dev/community-plugins
baseline_commit="270a3fa15d1a37a6a13ff3e0189414dc3ba05e06"
baseline_url="https://raw.githubusercontent.com/noctalia-dev/community-plugins/${baseline_commit}/catalog.toml"
current_url="https://raw.githubusercontent.com/noctalia-dev/community-plugins/main/catalog.toml"

baseline_ids=$(curl --fail --silent --show-error --location "$baseline_url" \
  | yq --input-format toml '.plugin[].id' | sort)
current_pairs=$(curl --fail --silent --show-error --location "$current_url" \
  | yq --input-format toml '.plugin[] | .id + "\t" + (.description // "")' | sort)

added=$(comm -13 <(echo "$baseline_ids") <(cut --fields=1 <<< "$current_pairs"))

if [[ -n "$added" ]]; then
  echo "New plugins since ${baseline_commit}:"
  while IFS=$'\t' read -r id description; do
    rg --quiet --fixed-strings --line-regexp "$id" <<< "$added" || continue
    echo "https://noctalia.dev/plugins/community/${id##*/}"
    echo "  ${description}"
    echo
  done <<< "$current_pairs"
else
  echo "No new plugins since ${baseline_commit}."
fi
