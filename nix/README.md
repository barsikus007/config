# [best Nix/OS config ever](../README.md)

modular Nix configurations for desktops, servers, virtual machines and mobile devices

## [packages](./packages/README.md)

## [command cheat sheet](./cheatsheet.md)

## installation

```shell
cd
git clone --depth=1 https://github.com/barsikus007/config
# cp config/nix/ ~/ && cd nix/
cd ~/config/nix/
sed --in-place 's/ogurez/YOUR_USERNAME/' flake.nix
sudo nixos-rebuild switch --flake .

#? enable pre-commit
cd ..
prek install
```

### Asus ROG G14 2020-2021 [fingerprint scanner](https://github.com/knauth/goodix-521d-explanation)

<https://github.com/goodix-fp-linux-dev/goodix-fp-dump/blob/master/README.md>

~~too lazy to write this on nix~~

`sudo $(nix build 'github:barsikus007/config?dir=nix#libs.goodix-patch-521d' --print-out-paths)/bin/run_521d`

(`OSError: [Errno 30] Read-only file system: 'clear-0.pgm'` output is <ins>__normal__</ins>)

### [NixOS Android](./hosts/android/README.md)

### [WSL distro](https://nix-community.github.io/NixOS-WSL/)

`sudo nixos-rebuild switch --flake .#NixOS-WSL`

### plain [nix installer](https://github.com/NixOS/nix-installer) on existing system

- TLDR
  - `curl --proto '=https' --tlsv1.2 --silent --show-error --fail --location https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes`
  - [offline](https://github.com/NixOS/nix-installer/releases/latest/download/nix-installer-x86_64-linux)
- [uninstaller](https://github.com/NixOS/nix-installer#uninstalling)
  - `/nix/nix-installer uninstall`

## config reference

### modules

#### [NixOS Windows VM with VFIO](./modules/vm/vfio/README.md)

### soft

#### [vscode](./.config/Code/User/README.md)

#### [mpv](./.config/mpv/README.md)

## other

- Steam
  - Top left steam logo > Settings > Compatibility
    - Enable steam play for all titles
    - Default compatibility tool: GE-Proton
  - [NTFS library fix](https://github.com/ValveSoftware/Proton/wiki/Using-a-NTFS-disk-with-Linux-and-Windows#preventing-ntfs-read-errors)
  - `nvidia-offload gamemoderun mangohud %command%`
- Throne (formerly known as nekoray/nekobox)
  - Routing -> Routing settings -> DNS -> Direct DNS: `8.8.8.8`
