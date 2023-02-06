cat <<EOT >> ~/.bash_aliases
alias grp='grep -Fin -C 7'
alias c='clear'
alias h='history'
alias hf='h|grp'
alias u='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'
alias dcu='docker compose up -d --build'
alias cdl='sudo sh -c "truncate -s 0 /var/lib/docker/containers/*/*-json.log"'
EOT

. ~/.bashrc
