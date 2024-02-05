#!/usr/bin/env bash

(
  set -Eeuo pipefail

  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

  cp -r "$script_dir/".[!.]* ~/
  ln -sf ~/.config/nvim/init.vim ~/.vimrc

  touch_file_if_not_exist() {
    # touches $1 if it does not exist
    if [ ! -f "$1" ]; then
      touch "$1"
    fi
  }

  add_line_if_not_exists() {
    # appends $1 to $2 if it does not exist
    if ! grep -q "$1" "$2"; then
      echo "$1" >>"$2"
    fi
  }

  create_bashrc() {
    # creates .bashrc if it does not exist
    touch_file_if_not_exist ~/.bashrc
  }

  create_bash_profile() {
    # creates .bash_profile if it does not exist
    touch_file_if_not_exist ~/.bash_profile
  }

  add_to_bashrc() {
    # appends $1 to bashrc if it does not exist
    add_line_if_not_exists "$1" ~/.bashrc
  }

  add_to_bash_profile() {
    # appends $1 to bash_profile if it does not exist
    add_line_if_not_exists "$1" ~/.bash_profile
  }

  create_bashrc
  create_bash_profile
  add_to_bash_profile '[ -f ~/.bashrc ] && source ~/.bashrc'
  # shellcheck disable=SC2016
  add_to_bashrc '[ -z "$XDG_CONFIG_HOME" ] && export XDG_CONFIG_HOME="$HOME/.config"'
  # shellcheck disable=SC2016
  add_to_bashrc '[ -f "$XDG_CONFIG_HOME/bash/config.bash" ] && source $XDG_CONFIG_HOME/bash/config.bash'
)
# shellcheck source=/dev/null
source ~/.bashrc
