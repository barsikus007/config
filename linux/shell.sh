#!/bin/sh

sudo wget https://github.com/adam7/delugia-code/releases/latest/download/delugia-complete.zip -O ~/delugia-complete.zip
mkdir ~/delugia-complete
unzip ~/delugia-complete.zip -d ~/delugia-complete
sudo mkdir /usr/share/fonts/delugia
sudo cp ~/delugia-complete/*.ttf /usr/share/fonts/delugia
sudo fc-cache -v
rm -rf ~/delugia-complete*

{
  register-python-argcomplete pipx;
  pdm completion bash;
  _HATCH_COMPLETE=bash_source hatch;
  starship completions bash;
} >> ~/.bash_completion
# pdm completion bash > /etc/bash_completion.d/pdm.bash-completion
