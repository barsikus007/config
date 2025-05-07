$cli=@"
#! scoop addons
scoop-search scoop-completion

#! base
mc bat duf gdu fzf btop neovim zoxide ripgrep
#? fd curl wget
#? btop-lhm VERY SLOW
#! add
eza tlrc yazi neofetch
#! pwsh/cmd specific
posh-git psfzf starship
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
#? mitmproxy httptoolkit goodbyedpi zapret
#? jetbrains-toolbox android-studio pycharm-professional
adb@33.0.3
adb@34.0.5
anydesk
audacity
ayugram
beyondcompare
brave
dbeaver
dupeguru
everything
ffmpeg
handbrake
iperf3
keepassxc
mpv
neovide
nmap
notepadplusplus
obs-studio
powertoys
python312
qbittorrent@4.1.9.1
qbittorrent@4.3.9
quicklook
remove-empty-directories
rufus
scrcpy
screentogif
ventoy
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
#? msiafterburner steamcmd
cheat-engine
ds4windows
graalvm
graalvm-oracle-jdk
graalvm20-jdk8
prismlauncher
"@


$bench=@"
cpu-z
crystaldiskinfo
crystaldiskmark
gpu-z
hwinfo
"@

$sort=@"
#! both
bind
ddu
gimp
irfanview
lessmsi
touch
#! laptop
cuda
cura
firefox
git-filter-repo
hashcat
qemu
sharex
sharpkeys
sophiapp
#! soft
apktool
cmake
curl
dismplusplus
exiftool
gcc
jd-gui
jexiftoolgui
make
obsidian
pe-bear
sysinternals
tor-browser
wireshark
x64dbg
"@

# # UNUSED
# camo-studio
# pshazz

# # BOT
# gifsicle
# imagemagick
# msys2
# tesseract
# tesseract-languages

Write-Host $base
