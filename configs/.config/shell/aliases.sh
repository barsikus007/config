#!/bin/sh

# https://askubuntu.com/a/22043
alias sudo='sudo '
alias xargs='xargs '

alias grp='grep -Fin -C 7'
alias c='clear'
alias h='history'
alias hf='h|grp'
alias ls='ls --color=auto'
alias l='ls -CF'
alias ll='ls -alF'
alias u='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'

alias cu='cd ~/config/ && git pull && ./configs/install.sh && cd -'

alias lzd='lazydocker'
alias dc='docker compose'
alias dcu='dc up -d --build'
alias dcp='dc ps'
alias dcs='dc stop'
alias dcd='dc down'
alias dcl='dc logs'
alias dcr='dc restart'
alias dce='dc exec -it'
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
