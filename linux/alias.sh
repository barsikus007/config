#!/bin/sh

cat <<EOT >> ~/.bash_aliases
alias grp='grep -Fin -C 7'
alias c='clear'
alias h='history'
alias hf='h|grp'
alias ls='ls --color=auto'
alias l='ls -CF'
alias ll='ls -alF'
alias u='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'
alias dcu='docker compose up -d --build'
alias dcp='docker compose ps'
alias dcl='docker compose logs'
alias cdl='sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"'

alias wgu="wg-quick up ~/wg0.conf"
alias wgd="wg-quick down ~/wg0.conf"
EOT

. ~/.bashrc
