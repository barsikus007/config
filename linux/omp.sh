# Linux
# TODO linux autoinstall
sudo wget https://github.com/adam7/delugia-code/releases/latest/download/delugia-complete.zip -O ~/delugia-complete.zip
mkdir ~/delugia-complete
unzip ~/delugia-complete.zip -d ~/delugia-complete
sudo mkdir /usr/share/fonts/delugia
sudo cp ~/delugia-complete/*.ttf /usr/share/fonts/delugia
sudo fc-cache -v
rm -rf ~/delugia-complete*

# https://starship.rs/
curl -sS https://starship.rs/install.sh | sh
cp starship.toml ~/.config/
echo 'eval "$(starship init bash)"' >> ~/.bashrc

# https://ohmyposh.dev/
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh
cp own.omp.json ~/.config
echo 'eval "$(oh-my-posh init bash --config ~/.config/own.omp.json)"' >> ~/.bashrc
# clear console due to render bug
echo 'c -x' >> ~/.bashrc
