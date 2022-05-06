# Linux
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
