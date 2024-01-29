$cli=@"
scoop-search scoop-completion
duf eza bat pwsh z starship fzf psfzf
clink clink-completions
lazydocker
#? curl psreadline
btop
#? btop-lhm VERY SLOW
cmake
ripgrep
#! unix tools
#? shim overrides
busybox
uutils-coreutils
which
grep
less
"@
#? clink inject; clink autorun install

$base=@"
$tools
#? archwsl
#? mitmproxy httptoolkit goodbyedpi
#? android-studio pycharm-professional
adb
anydesk
audacity
beyondcompare
brave
ffmpeg
hwinfo
iperf3
mpv
neovim
neovide
nmap
nvm
notepadplusplus
obs-studio
powertoys
python
qbittorrent
rufus
scrcpy
screentogif
sharex
telegram
vscode
winscp
wiztree
wsa-pacman
wumgr
yt-dlp
"@

$laptop=@"
battery-care
"@

$gaming=@"
ds4windows
#? msiafterburner steamcmd cheat-engine
"@


$other=@"

crystaldiskinfo
crystaldiskmark
"@

# # UNUSED
# camo-studio
# opera
# openjdk18
# pshazz
# poetry

# # BOT
# gifsicle
# imagemagick
# msys2
# tesseract
# tesseract-languages

# # HELD
# adb 33.0.3
# hwinfo 7.42-5030
# unrar 6.21
Write-Host $base
