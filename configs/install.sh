#!/usr/bin/env bash

set -Eeuo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

cp -r "$script_dir/".[!.]* ~/
ln -sf ~/.config/nvim/init.vim ~/.vimrc

create_bash_profile() {
  # creates .bash_profile if it does not exist
  (
    if [ ! -f ~/.bash_profile ]; then
        touch ~/.bash_profile
        # get if bahrc exists
        if [ -f ~/.bashrc ]; then
          cat '[ -f ~/.bashrc ] && source ~/.bashrc' >> ~/.bash_profile
        fi
    fi
  )
}

add_to_bash_profile() {
  # appends $1 to bash_profile if it does not exist
  (
    if ! grep -q "$1" ~/.bash_profile; then
        echo "$1" >> ~/.bash_profile
    fi
  )
}


create_bash_profile
add_to_bash_profile '[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"'
add_to_bash_profile '[ -f "$XDG_CONFIG_HOME/bash/config.bash" ] && source $XDG_CONFIG_HOME/bash/config.bash'
. ~/.bash_profile
