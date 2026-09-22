#!/usr/bin/env bash

#? package managers and updaters
alias cu='cd ~/config && git pull && ./linux/install.sh && cd -'
i() {
  if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
    pkg install "$@"
    return
  fi

  if [ -f /etc/os-release ]; then
    local os_info
    # shellcheck disable=SC1091
    os_info=$(. /etc/os-release && echo "${ID:-} ${ID_LIKE:-}")
    case "$os_info" in
      (*ubuntu*)
        if hash nala 2>/dev/null; then
          sudo nala install "$@"
        else
          sudo apt install "$@"
        fi
        return
        ;;
    esac
  fi

  echo "i: unsupported OS" >&2
  return 1
}
u() {
  if [ -n "${TERMUX_VERSION:-}" ] || [ -d "/data/data/com.termux" ]; then
    pkg update && pkg upgrade --assume-yes && pkg autoclean && pkg clean
    return
  fi

  if [ -f /etc/os-release ]; then
    local os_info
    # shellcheck disable=SC1091
    os_info=$(. /etc/os-release && echo "${ID:-} ${ID_LIKE:-}")
    case "$os_info" in
      (*ubuntu*)
        if hash nala 2>/dev/null; then
          sudo nala update && sudo nala upgrade --assume-yes && sudo nala autoremove --assume-yes && sudo nala clean
        else
          sudo apt update && sudo apt full-upgrade --assume-yes && sudo apt autoremove --assume-yes && sudo apt clean
        fi
        return
        ;;
    esac
  fi

  echo "u: unsupported OS" >&2
  return 1
}


confirm() {
  printf "%s [Y/n] " "$1"
  read -r resp < /dev/tty
  if [ "$resp" = "" ] || [ "$resp" = "Y" ] || [ "$resp" = "y" ] || [ "$resp" = "yes" ]; then
    return 0
  fi
  if [ "$2" = "abort" ]; then
    echo "Abort."
    echo
    exit 0
  fi
  return 1
}

setup_font() {
  (
    tmpfile=$(mktemp --suffix .zip)
    curl --silent --show-error --location https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip --output "$tmpfile"
    # /usr/share/fonts/truetype/cascadia ?
    sudo unzip -j "$tmpfile" 'ttf/Cascadia*.ttf' -d /usr/share/fonts/cascadia
    sudo fc-cache --verbose
    rm "$tmpfile"
  )
}

setup_docker() {
  (
    curl --silent --show-error --location https://get.docker.com | sh
    # seems like it's not needed
    # sudo groupadd docker
    sudo usermod --append --groups docker "$USER"
    newgrp docker; exit
  )
}

setup_user() {
  (
    echo "Creating $USER/.local/bin/ directory"
    mkdir --parents ~/.local/bin/
    if ! hash bat; then
      if hash batcat; then
        echo "Linking bat..."
        ln --symbolic "$(which batcat)" ~/.local/bin/bat
      else
        echo "batcat isn't installed to link"
      fi
    fi
    if ! hash starship; then
      echo "Setting up starship..."
      curl --silent --show-error https://starship.rs/install.sh | sh -s -- --yes --bin-dir="$HOME/.local/bin/"
    fi
    if ! hash yazi; then
      echo "Setting up yazi..."
      # TODO move zip installs to function
      tmpfile=$(mktemp --suffix .zip)
      curl --silent --show-error --location https://github.com/sxyazi/yazi/releases/latest/download/yazi-"$(uname --machine)"-unknown-linux-musl.zip --output "$tmpfile"
      unzip -j "$tmpfile" '*/yazi' -d ~/.local/bin/
      rm "$tmpfile"
    fi
    if ! hash bun; then
      #? interpreter for ~/.config/scripts/*.ts, not packaged in apt
      echo "Setting up bun..."
      case "$(uname --machine)" in
        (x86_64) bun_arch=x64 ;;
        (aarch64) bun_arch=aarch64 ;;
        (*) echo "no bun build for $(uname --machine)"; bun_arch='' ;;
      esac
      if [ -n "$bun_arch" ]; then
        tmpfile=$(mktemp --suffix .zip)
        curl --silent --show-error --location https://github.com/oven-sh/bun/releases/latest/download/bun-linux-"$bun_arch".zip --output "$tmpfile"
        unzip -j "$tmpfile" '*/bun' -d ~/.local/bin/
        rm "$tmpfile"
      fi
    fi
  )
}

setup_linux() {
  (
    echo "Setting up neovim shims..."
    for role in editor vi vim; do
      sudo update-alternatives --set $role "$(which nvim)"
    done
    # /usr/libexec/neovim/ is unstable thing, could broke
    for role in ex rview rvim view vimdiff; do
      sudo update-alternatives --set $role /usr/libexec/neovim/$role
    done
    echo "Creating /usr/local/bin/ directory"
    sudo mkdir --parents /usr/local/bin/
    if ! hash zellij; then
      echo "Setting up zellij..."
      curl --silent --show-error --location https://github.com/zellij-org/zellij/releases/latest/download/zellij-"$(uname --machine)"-unknown-linux-musl.tar.gz | sudo tar --extract --gzip --no-same-owner --directory /usr/local/bin/
      # sudo chmod +x /usr/local/bin/zellij
    fi
    setup_user
  )
}

setup_ubuntu() {
  # shellcheck disable=SC2086
  (
    soft_envs
    echo "Installing nala and $soft_unix $soft_base $soft_add $soft_add_ubuntu..."
    sudo apt install nala
    if [ ! -f /etc/apt/sources.list.d/nala-sources.list ]; then
      sudo nala fetch --auto
    fi
    u && \
    sudo nala install $soft_unix $soft_base $soft_add $soft_add_ubuntu --assume-yes
    confirm "Do you want to remove $soft_to_purge?" && sudo nala purge $soft_to_purge --assume-yes
    setup_linux
  )
}


#? ls replacement
llalias() {
  if hash eza &> /dev/null; then
    alias ll=ezall
    alias l=ezal
  else
    alias ll='ls --format=long -g --all --classify --escape --human-readable'
    alias l='ls --format=vertical --classify --escape --human-readable'
  fi
}

lllazy() {
  llalias
  alias ll
  eval ll "$@"
}

llazy() {
  llalias
  alias l
  eval l "$@"
}
