$cli=@"
#! scoop addons
scoop-search scoop-completion

#! essential
#? curl wget
#! base
jq fd mc bat duf gdu fzf btop neovim zoxide ripgrep
#? btop-lhm VERY SLOW
#! add
eza tlrc yazi fastfetch
#! pwsh/cmd specific
posh-git psfzf starship
clink clink-completions

lazydocker
#? psreadline
#! unix tools
#? cmake
busybox
#! shim overrides
#? uutils-coreutils
which
grep
less
"@
#? clink inject; clink autorun install

$base=@"
$cli
#? mitmproxy httptoolkit
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
qbittorrent@4.1.9.1
qbittorrent@4.3.9
quicklook
remove-empty-directories
rufus
scrcpy
screentogif
uv
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
#? msiafterburner steamcmd goggalaxy epic-games-launcher
autoclicker
cheat-engine
ds4windows

graalvm
graalvm-oracle-jdk
graalvm20-jdk8
graalvm21-jdk21
prismlauncher
amulet-map-editor
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
#! new
ani-cli
avidemux
bind
blender
bulk-crap-uninstaller
cinny
cuda
cursor
ddu
dotnet7-sdk
ds4windows
element
f3d
ffuf
git-lfs
httptoolkit
hxd
jetbrains-toolbox
lua
mitmproxy
mosh-client
mpv
msiafterburner
nbtexplorer
nekoray
nu
ollama
posh-git
qbittorrent
qemu
qtifw
reqable
simplex-chat
streamlink
superfile
syncthingtray
systeminformer-nightly
terminal-icons
universal-android-debloater
uv
vencord-installer
wezterm
winmtr
winscp
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
