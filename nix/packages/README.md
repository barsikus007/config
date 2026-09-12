# [best Nix/OS packages ever](../README.md)

```shell
# generic usage of autocompletion with your system nixpkgs
nix run --override-input nixpkgs nixpkgs github:barsikus007/config?dir=nix# <tab>
```

## coolvm example for non NixOS

user passwd is `0`

```shell
nix --extra-experimental-features "nix-command flakes" run --impure 'github:nix-community/nixGL' -- nix --extra-experimental-features "nix-command flakes" run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix'
```

- on WSL Ubuntu disable pipewire QEMU section and launch with pulseaudio
  - `-audiodev pa,id=snd0,server=/mnt/wslg/PulseServer -device intel-hda -device hda-output,audiodev=snd0`

## [index](https://github.com/barsikus007/config/blob/0fd574bce9a5778219e436d9665c692c2c30a2c8/nix/flake.nix#L453)

- [bcompare 5 diff tool](./bcompare5.nix)
  - `sed --in-place '/CheckID/d' ~/.config/bcompare5/BCState.xml.bak`
- [gcc locales patched for easy ISO format](./locales-iso.nix)
- [OpenWrt image](./packages/openwrt/xiaomi_ax3600.nix)
  - [uci](./packages/openwrt/dewclaw.nix)

### categorized

- fonts
  - [minecraftia 2](./auto/fonts/minecraftia.nix)
- games
  - [hytale launcher](./auto/games/hytale.nix)
    - rarely maintained
- gui
  - [davinci-resolve-communism](./auto/gui/davinci-resolve-studio.nix)
  - [keepassxc 2.8](./auto/gui/keepassxc.nix)
    - [source](https://github.com/keepassxreboot/keepassxc/tree/release/2.8.x)
  - [shikiwatch](./auto/gui/shikiwatch.nix)
    - example of unusual appimage packaging
- hax
  - [hack-captive-portals](./auto/hax/hack-captive-portals.nix)
- libs
  - [libspeedhack](./auto/libs/libspeedhack/package.nix)
  - [mprint label printer driver](./auto/libs/mprint.nix)
  - goodix fprint scanner drivers for ROG14
- soft
  - [adbfs with libfuse experemental](./auto/soft/adbfs-rootless-libfuse-3.nix)
  - [shdotenv](./auto/soft/shdotenv.nix)

### [kompas3d](./kompas3d)

```shell
nix run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#kompas3d-fhs'
# on non NixOS
nix --extra-experimental-features "nix-command flakes" run --impure --override-input nixpkgs nixpkgs 'github:nix-community/nixGL' -- env NIXPKGS_ALLOW_UNFREE=1 nix run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#kompas3d-fhs'
```

#### cleanup after store paths update

```shell
rm ~/.config/ascon/KOMPAS-3D/24/{recent_files.xml,KOMPAS.kit.config}
```

#### grdcontrol license service forwarding

```shell
# launch on computer with enough system parts (remote) lol
sudo NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features "nix-command flakes" run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#grdcontrol'
# launch on computer with kompas (client)
socat TCP-LISTEN:3189,bind=127.0.0.1,fork TCP:<remote_ip>:3189
```
