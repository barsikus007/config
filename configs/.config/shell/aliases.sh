#!/bin/sh

# https://askubuntu.com/a/22043
# https://superuser.com/a/1655578
alias sudo='sudo env PATH=$PATH '
# alias sudo='sudo -E env PATH=$PATH '
alias xargs='xargs '

# base
alias grp='grep -Fin -C 7'
alias c=clear
alias h=history
alias hf='h | grp'
alias sshe='editor ~/.ssh/config'
alias nv='editor $(fzf)'
alias nvf='editor $(find "/" | fzf)'
# shellcheck disable=SC2142
alias nvs='editor $(rg -n . | fzf | awk -F: '\''{print "+"$2,$1}'\'')'
alias 1ip='wget -qO - icanhazip.com'
alias 2ip='curl 2ip.ru'

# package managers and updaters
# TODO u functions which will resolve all
# TODO pacman color=auto ?
alias i='sudo apt install'
alias ii='sudo nala install'
alias uu='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'
alias uuu='sudo nala update && sudo nala upgrade -y && sudo nala autoremove -y && sudo nala clean'
alias u=uu
alias pacman='pacman --color=always'
alias cu='cd ~/config/ && git pull && ./configs/install.sh && cd -'

# ls
alias ezal='eza -F -bghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink'
alias ezall='eza -F -labghM --smart-group --group-directories-first --color=auto --color-scale --icons=always --no-quotes --hyperlink'
alias exal='exa -laFbgh --group-directories-first --color=auto --icons --color-scale'
alias exall='exa -laFbgh --group-directories-first --color=auto --icons --color-scale'
alias ls='ls --group-directories-first --color=auto --hyperlink'
alias ll=lllazy
alias l=llazy

# docker
alias lzd=lazydocker
alias lzdu='curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash'
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

# python
alias pipi='uv pip install -r requirements.txt || uv pip install -r pyproject.toml'
alias pyvcr='uv venv --allow-existing && source .venv/bin/activate && pipi'
alias pyv='source .venv/bin/activate || pyvcr'
alias pyt='ptpython'
alias pyta='pyt --asyncio'

# other
alias gdu="gdu -I ^/mnt"
alias zps='zpool status -v'

alias wgu='wg-quick up ~/wg0.conf'
alias wgd='wg-quick down ~/wg0.conf'

alias sex='explorer.exe .'

# https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/
alias open-ports='sudo lsof -i -P -n | grep LISTEN'

# ROG G14 specific aliases TODO detect if ROG G14 TODO install media and conf file
alias animeclr='asusctl anime -E false > /dev/null'
alias noanime='systemctl --user stop asusd-user && animeclr'
alias anime='animeclr && systemctl --user start asusd-user'
alias demosplash='asusctl anime pixel-image -p ~/.config/rog/bad-apple.png'
alias nodemo='tmux kill-session -t sound 2> /dev/null; noanime'
alias demo='nodemo && anime && sleep 0.5 && tmux new -s sound -d "play ~/Music/bad-apple.mp3 repeat -"'
