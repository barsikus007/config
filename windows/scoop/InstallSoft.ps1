# basic setup for scoop
scoop install mingit
scoop bucket add extras
scoop update
scoop install aria2
scoop config aria2-warning-enabled false
scoop install 7zip innounp dark

# fonts for terminal
scoop bucket add nerd-fonts
scoop install sudo
sudo scoop install delugia-nerd-font-complete

# vcredist
sudo scoop install vcredist-aio
#? scoop search build_tools

# terminal things
scoop install scoop-search scoop-completion
scoop install pwsh z starship fzf psfzf
#! scoop install oh-my-posh posh-git terminal-icons
#? scoop install clink clink-completions
#? clink inject; clink autorun install
scoop install which touch
#! scoop install curl psreadline

# other software
#? scoop install ds4windows msiafterburner steamcmd
#? scoop install pypy3 miniconda3
#? scoop install mitmproxy httptoolkit goodbyedpi
#? scoop install android-studio pycharm-professional

# archwsl
# anydesk
# # LAPTOP
# adb
# audacity
# discord
# ds4windows
# ffmpeg
# hwinfo
# iperf3
# mpv.net
# neovim
# nmap
# nvm
# notepadplusplus
# obs-studio
# opera
# powertoys
# python
# qbittorrent
# rufus
# scrcpy
# screentogif
# sharex
# telegram
# vscode
# windirstat
# wsa-pacman
# wumgr
# yt-dlp


# brave
# tor-browser

# gifsicle
# imagemagick
# msys2
# tesseract
# tesseract-languages

# crystaldiskmark
# openjdk18
# poetry
# pshazz
# winscp

# wireshark
