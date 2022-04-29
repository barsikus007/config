echo "alias grp='grep -Fin -A 7 -B 7'" >> ~/.bash_aliases
echo "alias c='clear'" >> ~/.bash_aliases
echo "alias h='history'" >> ~/.bash_aliases
echo "alias hf='h|grp'" >> ~/.bash_aliases
echo "alias u='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'" >> ~/.bash_aliases
echo "alias dcu='docker compose up -d --build'" >> ~/.bash_aliases