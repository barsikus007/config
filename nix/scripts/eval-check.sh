#!/usr/bin/env bash
set -euo pipefail

#? find flake directory containing flake.nix
if [ -f "./flake.nix" ]; then
  FLAKE_DIR="."
elif [ -f "./nix/flake.nix" ]; then
  FLAKE_DIR="./nix"
else
  FLAKE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fi

#? parse arguments or auto-discover targets
targets=()
if [ "$#" -gt 0 ]; then
  for arg in "$@"; do
    case "$arg" in
      (nixosConfigurations.* | homeConfigurations.* | nixOnDroidConfigurations.*)
        targets+=("$arg")
        ;;
      (*)
        #? prefix unqualified host name
        targets+=("nixosConfigurations.$arg")
        ;;
    esac
  done
else
  #? discover all configurations from flake outputs
  if nixos_json=$(nix eval --json "${FLAKE_DIR}#nixosConfigurations" --apply builtins.attrNames 2>/dev/null); then
    while IFS= read -r host; do
      [ -n "$host" ] && targets+=("nixosConfigurations.$host")
    done < <(printf '%s' "$nixos_json" | jq --raw-output '.[]')
  fi

  if hm_json=$(nix eval --json "${FLAKE_DIR}#homeConfigurations" --apply builtins.attrNames 2>/dev/null); then
    while IFS= read -r host; do
      [ -n "$host" ] && targets+=("homeConfigurations.$host")
    done < <(printf '%s' "$hm_json" | jq --raw-output '.[]')
  fi

  if droid_json=$(nix eval --json "${FLAKE_DIR}#nixOnDroidConfigurations" --apply builtins.attrNames 2>/dev/null); then
    while IFS= read -r host; do
      [ -n "$host" ] && targets+=("nixOnDroidConfigurations.$host")
    done < <(printf '%s' "$droid_json" | jq --raw-output '.[]')
  fi
fi

if [ "${#targets[@]}" -eq 0 ]; then
  echo "no targets found to evaluate"
  exit 1
fi

tmp_dir=$(mktemp --directory)
trap 'rm --recursive --force "$tmp_dir"' EXIT

#? glob patterns to skip when auto-discovering targets
read -r -a SKIP_PATTERNS <<< "${EVAL_SKIP:-coolvm* *Iso*}"

#? filter out skipped targets
filtered_targets=()
for target in "${targets[@]}"; do
  skip=0
  for pattern in "${SKIP_PATTERNS[@]}"; do
    # shellcheck disable=SC2254
    case "$target" in
      ($pattern | *.${pattern}) skip=1 ;;
    esac
  done
  if [ "$skip" -eq 0 ]; then
    filtered_targets+=("$target")
  else
    printf '  skipping %s (matches SKIP_PATTERNS)\n' "$target"
  fi
done
targets=("${filtered_targets[@]}")

timeout_sec="${EVAL_TIMEOUT:-300s}"
report_file="${EVAL_REPORT:-eval-errors.md}"
passed=0
failed=0
failed_targets=()

printf 'evaluating %d target(s)...\n' "${#targets[@]}"

for target in "${targets[@]}"; do
  eval_attr=""
  extra_flags=()
  case "$target" in
    (nixosConfigurations.*)
      host="${target#nixosConfigurations.}"
      eval_attr="${FLAKE_DIR}#nixosConfigurations.\"${host}\".config.system.build.toplevel.drvPath"
      ;;
    (homeConfigurations.*)
      host="${target#homeConfigurations.}"
      eval_attr="${FLAKE_DIR}#homeConfigurations.\"${host}\".activationPackage.drvPath"
      ;;
    (nixOnDroidConfigurations.*)
      #? nix-on-droid upstream hardcodes store path strings, requiring impure eval
      extra_flags+=(--impure)
      host="${target#nixOnDroidConfigurations.}"
      eval_attr="${FLAKE_DIR}#nixOnDroidConfigurations.\"${host}\".activationPackage.drvPath"
      ;;
    (*)
      eval_attr="${FLAKE_DIR}#${target}"
      ;;
  esac

  printf '  evaluating %s... ' "$target"
  start_time=$(date +%s)
  err_file="${tmp_dir}/${target}.err"

  if timeout --kill-after=10s "$timeout_sec" nix eval --raw --show-trace "${extra_flags[@]}" "$eval_attr" >/dev/null 2>"$err_file"; then
    duration=$(( $(date +%s) - start_time ))
    printf '\033[32m[OK]\033[0m (%ds)\n' "$duration"
    passed=$((passed + 1))
  else
    duration=$(( $(date +%s) - start_time ))
    printf '\033[31m[FAIL]\033[0m (%ds)\n' "$duration"
    failed=$((failed + 1))
    failed_targets+=("$target")
  fi
done

printf '\nevaluation complete: %d passed, %d failed of %d total\n' "$passed" "$failed" "${#targets[@]}"

if [ "$failed" -gt 0 ]; then
  {
    printf '# flake evaluation failures (%d of %d failed)\n\n' "$failed" "${#targets[@]}"
    printf '## failed targets\n\n'
    for ft in "${failed_targets[@]}"; do
      printf -- "- \`%s\`\n" "$ft"
    done
    printf '\n---\n\n'

    for ft in "${failed_targets[@]}"; do
      printf "### \`%s\`\n\n\`\`\`text\n" "$ft"
      cat "${tmp_dir}/${ft}.err"
      printf '\n```\n\n'
    done
  } > "$report_file"

  #? append report to GitHub Actions summary when running in CI
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    cat "$report_file" >> "$GITHUB_STEP_SUMMARY"
  fi

  printf '\033[31mreport saved to %s\033[0m\n' "$report_file"
  exit 1
fi

printf '\033[32mall targets evaluated successfully\033[0m\n'
exit 0
