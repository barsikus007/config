# [Termux](./)

## adb shell with termux (root needed)

.adbrc creation

```shell
cat > /data/data/com.termux/files/home/.adbrc << "EOF"
#!/data/data/com.termux/files/usr/bin/bash

export PREFIX="/data/data/com.termux/files"
export HOME="$PREFIX/home"
export LD_LIBRARY_PATH="$PREFIX/usr/lib"
export PATH="$PATH:$HOME/.local/bin:$PREFIX/usr/bin"
export LANG="en_US.UTF-8"
cd $HOME
. $PREFIX/usr/etc/profile

/data/data/com.termux/files/usr/bin/login
EOF
chmod +x /data/data/com.termux/files/home/.adbrc
```

essential aliases

```shell
cat > /data/data/com.termux/files/home/.bash_profile << "EOF"
source .bash_aliases
EOF
cat > /data/data/com.termux/files/home/.bash_aliases << "EOF"
alias ll='ls -la'
EOF
```

enter shell

```shell
adb shell -t "su -c /data/data/com.termux/files/home/.adbrc"
# or with termux user
adb shell -t 'su $(su -c "stat -c %U /data/data/com.termux") -c /data/data/com.termux/files/home/.adbrc'
# or without .adbrc
adb shell -t "su -c /data/data/com.termux/files/usr/bin/login"
# or for nix-on-droid https://github.com/nix-community/nix-on-droid/issues/248
adb shell -t 'su $(su -c "stat -c %U /data/data/com.termux.nix") -c /data/data/com.termux.nix/files/usr/bin/login'
#! NEVER REBUILD SYSTEM FROM ADB SHELL
```

## sync ssh folder

```shell
nix shell nixpkgs#rsync
rsync -avz --delete --chmod=F0600 --no-owner --no-group storage/shared/Documents/Sync/home/.ssh/ ~/.ssh/
```

## vanilla setup

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
