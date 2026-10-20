# [Termux](./)

## [setup](../../linux/README.md)

tldr:

```shell
pkg install git --assume-yes
cd && git clone --depth=1 https://github.com/barsikus007/config && cd -
cd ~/config && git pull && ./linux/install.sh && cd -
setup_termux
```

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
