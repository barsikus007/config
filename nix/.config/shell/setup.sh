#!/bin/sh

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

soft_envs() {
  soft_unix="git curl wget"
  soft_base="mc bat duf gdu fzf btop neovim zoxide ripgrep"
  # fd make bzip2
  soft_add="eza tmux tree neofetch"
  soft_add_ubuntu="nala build-essential software-properties-common"
  soft_to_purge="snapd"
}

setup_font() {
  (
    tmpfile=$(mktemp --suffix .zip)
    wget https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip -O "$tmpfile"
    # /usr/share/fonts/truetype/cascadia ?
    sudo unzip -j "$tmpfile" ttf/Cascadia*.ttf -d /usr/share/fonts/cascadia
    sudo fc-cache -v
    rm "$tmpfile"
  )
}

setup_docker() {
  (
    curl -sSL https://get.docker.com | sh
    # seems like it's not needed
    # sudo groupadd docker
    sudo usermod -aG docker "$USER"
    newgrp docker; exit
  )
}

setup_user() {
  (
    if ! hash bat; then
      if hash batcat; then
        echo "Linking bat..."
        mkdir -p ~/.local/bin
        ln -s "$(which batcat)" ~/.local/bin/bat
      else
        echo "batcat isn't installed to link"
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
    if ! hash starship; then
      echo "Setting up starship..."
      curl -sS https://starship.rs/install.sh | sh
    fi
    setup_user
  )
}

setup_ubuntu() {
  # shellcheck disable=SC2086
  (
    soft_envs
    echo "Installing nala and $soft_unix $soft_base $soft_add $soft_add_ubuntu..."
    sudo apt install nala && \
    sudo nala fetch --auto && \
    uuu && \
    sudo nala install $soft_unix $soft_base $soft_add $soft_add_ubuntu -y
    confirm "Do you want to remove $soft_to_purge?" && sudo nala purge $soft_to_purge -y
    setup_linux
  )
}

setup_arch() {
  # shellcheck disable=SC2086
  (
    soft_envs
    sudo pacman -S $soft_unix $soft_base $soft_add -y
    sudo pacman -Rsn $soft_to_purge -y
    setup_linux
  )
}

llalias() {
  if hash eza &> /dev/null; then
    alias ll=ezall
    alias l=ezal
  elif hash exa &> /dev/null; then
    alias ll=exall
    alias l=exal
  else
    alias ll='ls -laFbgh'
    alias l='ls -CFbh'
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
