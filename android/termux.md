# [Termux](./)

from PC (root needed)

```shell
adb shell -t "su -c /data/data/com.termux/files/usr/bin/login"

export PREFIX="/data/data/com.termux/files"
export HOME="$PREFIX/home"
export LD_LIBRARY_PATH="$PREFIX/usr/lib"
export PATH="$PATH:$HOME/.local/bin:$PREFIX/usr/bin"
export LANG="en_US.UTF-8"
cd $HOME
. $PREFIX/usr/etc/profile


# https://github.com/nix-community/nix-on-droid/issues/248
adb shell -t 'su $(su -c "stat -c %U /data/data/com.termux.nix") -c /data/data/com.termux.nix/files/usr/bin/login'
```

```shell
termux-setup-storage
yes | pkg up
# unix
pkg i git curl wget iproute2 -y
# base
pkg i bat duf gdu fzf btop neovim zoxide ripgrep -y
# add
pkg i eza tree zellij -y
pkg i python -y
# add termix (no tsu)
pkg i termux-api -y

# fonts
#? https://github.com/lsd-rs/lsd/issues/423
tmpfile=$(mktemp --suffix .zip)
curl -sSL https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip -o "$tmpfile"
unzip -j "$tmpfile" 'ttf/Cascadia*.ttf' -d /data/data/com.termux/files/usr/share/fonts/cascadia
ln -s /data/data/com.termux/files/usr/share/fonts/cascadia/CascadiaCodeNF.ttf ~/.termux/font.ttf
```
