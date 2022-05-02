# configure installation
$env:SCOOP='D:\scoop'
[environment]::setEnvironmentVariable('SCOOP',$env:SCOOP,'User')
# run the installer
iwr -useb get.scoop.sh | iex; scoop install mingit; scoop bucket add extras; scoop update; scoop install aria2; scoop config aria2-warning-enabled false

scoop install oh-my-posh posh-git terminal-icons
scoop install scoop-search scoop-completion

# scoop install z
# scoop install starship
# scoop install pwsh? psreadline fzf psfzf
# scoop install clink clink-completions


# scoop bucket add nerd-fonts
# scoop install sudo
# sudo scoop install delugia-nerd-font-complete
# sudo scoop install Delugia-Nerd-Font-Complete


# scoop install ds4windows msiafterburner pypy3 ffmpeg
# which touch httptoolkit mitmproxy steamcmd winget? curl? windows-terminal? miniconda3?

# # LAPTOP
# 7zip
# adb
# anydesk
# audacity
# discord
# ds4windows
# ffmpeg
# hwinfo
# iperf3
# mpv.net
# neovim
# nmap
# nodejs-lts
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
# innounp
# openjdk18
# poetry
# pshazz
# winscp

# mitmproxy
# wireshark
