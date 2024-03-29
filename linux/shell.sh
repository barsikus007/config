#!/bin/sh

sudo wget https://github.com/adam7/delugia-code/releases/latest/download/delugia-complete.zip -O ~/delugia-complete.zip
mkdir ~/delugia-complete
unzip ~/delugia-complete.zip -d ~/delugia-complete
sudo mkdir /usr/share/fonts/delugia
sudo cp ~/delugia-complete/*.ttf /usr/share/fonts/delugia
sudo fc-cache -v
rm -rf ~/delugia-complete*

# https://starship.rs/
curl -sS https://starship.rs/install.sh | sh

# bat ubuntu workaround
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat

# python tools
python3 -m pip install --user pipx
python3 -m pipx ensurepath
pipx install hatch
pipx install poetry

{
  register-python-argcomplete pipx;
  poetry completions bash;
  _HATCH_COMPLETE=bash_source hatch;
  starship completions bash;
} >> ~/.bash_completion
