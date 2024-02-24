$cli=@"
#! scoop addons
scoop-search scoop-completion

#! base (git installed as mingit)
mc bat duf btop neovim ripgrep neofetch
#? btop-lhm VERY SLOW
#! add
eza
#! pwsh specific
pwsh z starship fzf psfzf
clink clink-completions

lazydocker
#? curl psreadline
cmake
#! unix tools
busybox
#? shim overrides
uutils-coreutils
which
grep
less
"@
#? clink inject; clink autorun install

$base=@"
$cli
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
neovide
nmap
notepadplusplus
obs-studio
powertoys
python312
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
