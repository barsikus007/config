#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

cp -r "$script_dir/".[!.]* ~/
ln -sf ~/.config/nvim/init.vim ~/.vimrc

add_to_bashrc() {
  # appends $1 to bashrc if it does not exist
  (
    if ! grep -q "$1" ~/.bashrc; then
        echo "$1" >> ~/.bashrc
    fi
  )
}

if [ ! -f ~/.bashrc ]; then
  touch ~/.bashrc
fi
add_to_bashrc '[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"'
add_to_bashrc '[ -f "$XDG_CONFIG_HOME/bash/config.bash" ] && source $XDG_CONFIG_HOME/bash/config.bash'
. ~/.bashrc
