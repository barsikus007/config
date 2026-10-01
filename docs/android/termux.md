# [Termux](./)

## adb shell with termux (root needed)

`.adbrc` creation

```shell
cat > /data/data/com.termux/files/home/.adbrc << "EOF"
#!/data/data/com.termux/files/usr/bin/bash

export PREFIX="/data/data/com.termux/files"
export HOME="$PREFIX/home"
export PATH="$HOME/.local/bin:$PREFIX/usr/bin:$PATH"
export LANG="en_US.UTF-8"
export TERM="${TERM:-xterm-256color}"
cd "$HOME"

$PREFIX/usr/bin/login
EOF
chmod +x /data/data/com.termux/files/home/.adbrc
```

essential aliases

```shell
cat > /data/data/com.termux/files/home/.bash_profile << "EOF"
source .bash_aliases
EOF
cat > /data/data/com.termux/files/home/.bash_aliases << "EOF"
alias ll='ls --format=long --all'
EOF
```

enter shell

```shell
adb shell -t "su --command /data/data/com.termux/files/home/.adbrc"
# or with termux user
adb shell -t 'su $(su --command "stat --format %U /data/data/com.termux") --command /data/data/com.termux/files/home/.adbrc'
# or without .adbrc
adb shell -t "su --command /data/data/com.termux/files/usr/bin/login"
# or for nix-on-droid https://github.com/nix-community/nix-on-droid/issues/248#issuecomment-3619760126
adb shell -t 'su $(su --command "stat --format %U /data/data/com.termux.nix") --command /data/data/com.termux.nix/files/usr/bin/login'
#! NEVER REBUILD SYSTEM FROM ADB SHELL
```

## sync ssh folder

```shell
nix shell nixpkgs#rsync
rsync --verbose --archive --delete --chmod=F0600 --no-owner --no-group storage/shared/Documents/Sync/home/.ssh/ ~/.ssh/
```

## vanilla setup

```shell
termux-setup-storage
yes | pkg up
# unix
pkg i git curl wget iproute2 --assume-yes
# base
pkg i bat duf gdu fzf btop neovim zoxide ripgrep --assume-yes
# add
pkg i eza tree zellij --assume-yes
pkg i python --assume-yes
# add termix (no tsu)
pkg i termux-api --assume-yes

# fonts
#? https://github.com/lsd-rs/lsd/issues/423
tmpfile=$(mktemp --suffix .zip)
curl --silent --show-error --location https://github.com/microsoft/cascadia-code/releases/download/v2407.24/CascadiaCode-2407.24.zip --output="$tmpfile"
unzip -j "$tmpfile" 'ttf/Cascadia*.ttf' -d /data/data/com.termux/files/usr/share/fonts/cascadia
ln --symbolic /data/data/com.termux/files/usr/share/fonts/cascadia/CascadiaCodeNF.ttf ~/.termux/font.ttf
```
