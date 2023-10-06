#!/bin/sh

alias grp='grep -Fin -C 7'
alias c='clear'
alias h='history'
alias hf='h|grp'
alias ls='ls --color=auto'
alias l='ls -CF'
alias ll='ls -alF'
alias u='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'
alias lzd='lazydocker'
alias dcu='docker compose up -d --build'
alias dcp='docker compose ps'
alias dcs='docker compose stop'
alias dcd='docker compose down'
alias dcl='docker compose logs'
alias cdl='sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"'

alias wgu="wg-quick up ~/wg0.conf"
alias wgd="wg-quick down ~/wg0.conf"

# ROG G14 specific aliases TODO detect if ROG G14
alias animeclr='asusctl anime -c > /dev/null'
alias noanime='systemctl --user stop asusd-user && animeclr'
alias anime='animeclr && systemctl --user start asusd-user'
alias demosplash='asusctl anime pixel-image -p ~/.config/rog/bad-apple.png'
alias nodemo='tmux kill-session -t sound 2> /dev/null; noanime'
alias demo='nodemo && anime && sleep 0.5 && tmux new -s sound -d "play ~/Music/bad-apple.mp3 repeat -"'
