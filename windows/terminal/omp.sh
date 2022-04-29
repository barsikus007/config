# INSTALL FONT
# TODO linux autoinstall
https://github.com/adam7/delugia-code/releases/latest/download/delugia-complete.zip

# WSL
# https://starship.rs/
# curl -sS https://starship.rs/install.sh | sh
# ~/.config/starship.toml
# omp
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

# sudo apt install unzip

# mkdir ~/.poshthemes
# wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
# unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
# chmod u+rw ~/.poshthemes/*.json
# rm ~/.poshthemes/themes.zip

mkdir ~/.poshthemes
cp own.omp.json ~/.poshthemes
echo 'eval "$(oh-my-posh init bash --config ~/.poshthemes/own.omp.json)"' >> ~/.bashrc
# clear console due to render bug
echo 'c -x' >> ~/.bashrc

echo "alias grp='grep -Fin -A 7 -B 7'" >> ~/.bash_aliases
echo "alias c='clear'" >> ~/.bash_aliases
echo "alias h='history'" >> ~/.bash_aliases
echo "alias hf='h|grp'" >> ~/.bash_aliases
echo "alias u='sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean'" >> ~/.bash_aliases

# THEMES
# jandedobbeleer
# iterm2
# slim
# slimfat
# paradox
# blueish
# pixelrobots