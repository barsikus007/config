#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

cp -r "$script_dir/".[!.]* ~/
ln -s ~/.config/nvim/init.vim ~/.vimrc
