#!/usr/bin/env bash
#? bash nix/home/desktop/manager/quickshell/check-noctalia-plugins.sh
set -euo pipefail

#? https://noctalia.dev/plugins
#? https://github.com/noctalia-dev/community-plugins
baseline_commit="ca07934"
baseline_url="https://raw.githubusercontent.com/noctalia-dev/community-plugins/${baseline_commit}/catalog.toml"
current_url="https://raw.githubusercontent.com/noctalia-dev/community-plugins/main/catalog.toml"

baseline_ids=$(curl --fail --silent --show-error --location "$baseline_url" \
  | rg --only-matching --replace '$1' 'id = "([^"]+)"' | sort)
current_ids=$(curl --fail --silent --show-error --location "$current_url" \
  | rg --only-matching --replace '$1' 'id = "([^"]+)"' | sort)

added=$(comm -13 <(echo "$baseline_ids") <(echo "$current_ids"))

if [[ -n "$added" ]]; then
  echo "New plugins since ${baseline_commit}:"
  while IFS= read -r id; do
    echo "https://noctalia.dev/plugins/community/${id##*/}"
  done <<< "$added"
else
echo "No new plugins since ${baseline_commit}."
fi
