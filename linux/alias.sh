cat <<EOT >> greetings.txt
alias grp='grep -Fin -A 7 -B 7'
alias c='clear'
alias h='history'
alias hf='h|grp'
alias u='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'
alias dcu='docker compose up -d --build'
EOT

. ~/.bashrc
