# [Worst Nix/OS packages ever](../README.md)

```shell
# generic usage of autocompletion with your system nixpkgs
nix run --override-input nixpkgs nixpkgs github:barsikus007/config?dir=nix# <tab>
```

## index

- [adbfs with libfuse experemental](./adbfs-rootless-libfuse-3.nix)
- [anicli anime TUI client](./anicli-ru/)
- [bcompare 5 diff tool](./bcompare5.nix)
- [davinci-resolve communism edition](./davinci-resolve-studio.nix)
- TODO
- [minecraftia 2 font](./minecraftia.nix)
- TODO

### [kompas3d](./kompas3d)

```shell
nix run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#kompas3d-fhs'
# on non NixOS
nix --extra-experimental-features "nix-command flakes" run --impure --override-input nixpkgs nixpkgs 'github:nix-community/nixGL' -- env NIXPKGS_ALLOW_UNFREE=1 nix run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#kompas3d-fhs'
```

### cleanup after store paths update

```shell
rm ~/.config/ascon/KOMPAS-3D/24/{recent_files.xml,KOMPAS.kit.config}
```

### grdcontrol license service forwarding

```shell
# launch on computer with enough system parts (remote) lol
sudo NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features "nix-command flakes" run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#grdcontrol'
# launch on computer with kompas (client)
socat TCP-LISTEN:3189,bind=127.0.0.1,fork TCP:<remote_ip>:3189
```
