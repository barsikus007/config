#!/bin/sh

# https://askubuntu.com/a/22043
alias sudo='sudo '
alias xargs='xargs '

alias grp='grep -Fin -C 7'
alias c='clear'
alias h='history'
alias hf='h | grp'

# package managers and updaters
# TODO u functions which will resolve all
alias uu='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'
alias uuu='sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo nala clean'
alias u='uu'
alias pacman='pacman --color always'
alias cu='cd ~/config/ && git pull && ./configs/install.sh && cd -'
alias lzdu='curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash'

alias ezal='eza -F -bghM --smart-group --group-directories-first --color=always --color-scale --icons=always --no-quotes --hyperlink'
alias ezall='eza -F -labghM --smart-group --group-directories-first --color=always --color-scale --icons=always --no-quotes --hyperlink'
alias exal='exa -laFbgh --group-directories-first --color=always --icons --color-scale'
alias exall='exa -laFbgh --group-directories-first --color=always --icons --color-scale'
alias ls='ls --group-directories-first --color=always --hyperlink'
alias ll=lllazy
alias l=llazy

alias lzd='lazydocker'
alias dsp='docker system prune'
alias dspa='dsp --all'
alias dc='docker system prune'
alias dc='docker compose'
alias dcu='dc up -d'
alias dcub='dcu --build'
alias dcuo='dcu --remove-orphans'
alias dcup='dc -f compose.prod.yaml up -d'
alias dcp='dc ps'
alias dcs='dc stop'
alias dcd='dc down'
alias dcl='dc logs'
alias dcr='dc restart'
alias dce='dc exec -it'
alias cdl='sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"'

alias pyvcr='python3 -m venv .venv --upgrade-deps && .venv/bin/pip install -r requirements.txt && source .venv/bin/activate'
alias pyv='source .venv/bin/activate || pyvcr'
alias pyt='ptpython --asyncio'
alias pipi='python -c "import os;os.environ[\"VIRTUAL_ENV\"]" && pip install -r requirements.txt || echo "activate venv to install requirements"'

# remove color after 24.04
alias ncdu="ncdu --color dark --exclude '/mnt/*'"
alias zps='zpool status -v'

alias wgu='wg-quick up ~/wg0.conf'
alias wgd='wg-quick down ~/wg0.conf'

alias sex='explorer.exe .'

# https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
alias open-ports='sudo lsof -i -P -n | grep LISTEN'

# ROG G14 specific aliases TODO detect if ROG G14
alias animeclr='asusctl anime -c > /dev/null'
alias noanime='systemctl --user stop asusd-user && animeclr'
alias anime='animeclr && systemctl --user start asusd-user'
alias demosplash='asusctl anime pixel-image -p ~/.config/rog/bad-apple.png'
alias nodemo='tmux kill-session -t sound 2> /dev/null; noanime'
alias demo='nodemo && anime && sleep 0.5 && tmux new -s sound -d "play ~/Music/bad-apple.mp3 repeat -"'
