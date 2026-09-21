#!/usr/bin/env bash

#? davinci resolve studio overlayfs runner and builder
#? exports closure to /tank/storage/downloads/davinci and mounts over /nix/store

davinci_build() {
  local dest_dir="/tank/storage/downloads/davinci"
  local flake_path="/home/ogurez/config/nix"
  local manifest="$dest_dir/.installed-paths"
  local out_path="${1:-}"

  mkdir --parents "$dest_dir"
  touch "$manifest"

  if [ -z "$out_path" ]; then
    echo "building davinci..."
    out_path=$(nom build "$flake_path#davinci-resolve-studio" --no-link --print-out-paths)
  fi

  local reqs_file
  reqs_file=$(mktemp)
  nix-store --query --requisites "$out_path" | sort --unique > "$reqs_file"

  if [ -d "$dest_dir/nix/store" ]; then
    for entry in "$dest_dir"/nix/store/*; do
      [ -e "$entry" ] || continue
      local store_path="/nix/store/${entry##*/}"
      if ! rg --quiet --fixed-strings --line-regexp "$store_path" "$reqs_file" 2>/dev/null; then
        echo "removing obsolete store path: ${entry##*/}"
        chmod --recursive u+w "$entry"
        rm --recursive --force "$entry"
      fi
    done
  fi

  if [ -s "$manifest" ]; then
    local valid_manifest
    valid_manifest=$(mktemp)
    rg --fixed-strings --line-regexp --file "$reqs_file" "$manifest" > "$valid_manifest" 2>/dev/null || true
    mv --force "$valid_manifest" "$manifest"
  fi

  local missing_paths=()
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    if ! rg --quiet --fixed-strings --line-regexp "$p" "$manifest" 2>/dev/null || [ ! -e "$dest_dir$p" ]; then
      if [ -e "$dest_dir$p" ]; then
        echo "cleaning up incomplete path before re-extract: ${p##*/}"
        chmod --recursive u+w "$dest_dir$p"
        rm --recursive --force "$dest_dir$p"
      fi
      missing_paths+=("$p")
    fi
  done < "$reqs_file"
  rm --force "$reqs_file"

  if [ "${#missing_paths[@]}" -gt 0 ]; then
    echo "exporting ${#missing_paths[@]} store paths to $dest_dir/nix/store..."
    tar --create --hard-dereference --file - --files-from <(printf '%s\n' "${missing_paths[@]}") \
      | tar --extract --delay-directory-restore --file - --directory "$dest_dir"

    printf '%s\n' "${missing_paths[@]}" >> "$manifest"
    sort --unique --output "$manifest" "$manifest"
  else
    echo "all store paths are already up to date in $dest_dir"
  fi

  if [ -d "$out_path/bin" ]; then
    echo "$out_path/bin/davinci-resolve-studio" > "$dest_dir/current-bin"
  else
    echo "$out_path" > "$dest_dir/current-bin"
  fi
  echo "done. exported size: $(du --human-readable --summarize "$dest_dir/nix/store" | cut --fields=1)"
}

davinci_run() {
  local dest_dir="/tank/storage/downloads/davinci"
  local bin_path_file="$dest_dir/current-bin"
  local bundle_store="$dest_dir/nix/store"

  if [ ! -f "$bin_path_file" ]; then
    echo "error: $bin_path_file not found. run davinci_build first." >&2
    return 1
  fi

  if [ ! -d "$bundle_store" ]; then
    echo "error: $bundle_store not found. run davinci_build first." >&2
    return 1
  fi

  local bin_path
  bin_path=$(cat "$bin_path_file")

  # shellcheck disable=SC2016
  unshare --user --map-root-user --mount bash -c '
    bundle_store="$1"
    bin_path="$2"
    shift 2
    mount -t overlay overlay -o lowerdir="$bundle_store":/nix/store /nix/store
    exec "$bin_path" "$@"
  ' -- "$bundle_store" "$bin_path" "$@"
}

davinci_nvidia() {
  local opencl_dir="/tmp/davinci-opencl"
  mkdir --parents "$opencl_dir"
  ln --symbolic --force /run/opengl-driver/etc/OpenCL/vendors/nvidia.icd "$opencl_dir/nvidia.icd"

  OCL_ICD_VENDORS="$opencl_dir" nvidia-offload zsh -c 'davinci_run "$@"' _ "$@"
}

davinci() {
  davinci_nvidia "$@"
}
