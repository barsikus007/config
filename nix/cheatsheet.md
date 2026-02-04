# [cheatsheet](./README.md)

## nixpkgs

- [index](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix)
  - `code $(nix eval -f '<nixpkgs>' path)/pkgs/top-level/all-packages.nix`
- [phases order](https://nixos.org/manual/nixpkgs/stable/#sec-stdenv-phases)
- [builder status nixos-unstable](https://hydra.nixos.org/jobset/nixos/trunk-combined/latest-eval)
- [attributes ordering](https://github.com/jtojnar/nixpkgs-hammering/blob/main/explanations/attribute-ordering.md)

### speedtest

feat: gemini

```shell
# 1. Вычисляем хэш текущего ядра Linux из пути в /nix/store
HASH=$(readlink -f /run/current-system/kernel | grep -oP '/nix/store/\K[a-z0-9]{32}')

# 2. Получаем прямой URL к .nar архиву из кэша
NAR_URL=$(curl -s https://cache.nixos.org/$HASH.narinfo | grep -oP 'URL: \K.*')

# 3. Если файл найден в кэше — качаем и замеряем скорость
if [ -z "$NAR_URL" ]; then
  echo "Ваше ядро собрано локально или отсутствует в кэше. Попробуйте другой пакет."
else
  echo "Тестируем на файле: $NAR_URL"
  curl -L -o /dev/null -w "Speed: %{speed_download} B/s\n" "https://cache.nixos.org/$NAR_URL"
fi
```

### misc

- ventoy: `NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_INSECURE=1 nix shell --impure nixpkgs#ventoy-full-qt`
  - `sudo ventoy-gui /dev/...`
  - `sudo ventoy-plugson /dev/...`

## nixos

### nixos-rebuild

```shell
# no internet
nh os switch /home/ogurez/config/nix -- --option substitute false
```

### ISO with initial soft

```shell

nix build ./nix#nixosMinimalIso
dd bs=4M conv=fsync oflag=direct status=progress if=./result/iso/nixos-minimal- of=/dev/sd
qemu-system-x86_64 -enable-kvm -m 256 -cdrom result/iso/nixos-minimal*.iso -nic user,hostfwd=tcp::2222-:22
qemu-system-x86_64 -enable-kvm -m 2048 -smp 4 -cdrom result/iso/nixos-graphical*.iso -nic user,hostfwd=tcp::2222-:22
ssh root@localhost -p 2222
# or just
nixos-rebuild build-vm --flake ./nix#minimalIso-x86_64-linux
nh os build-vm --hostname minimalIso-x86_64-linux
nh os build-vm --hostname minimalIso-x86_64-linux && ./result/bin/run-nixos-vm
```

#### Paste How-To

QEMU console is `Ctrl+Shift+2`, to return `Ctrl+Shift+1` then idk
Add `-serial stdio` to QEMU cmd

### show only enabled programs/services

```nix
let
  lib = pkgs.lin;
  toCheck = config.programs;
  # toCheck = config.services;
  blacklist = [ "redis" ];
in
let
  names = builtins.attrNames toCheck;
  getEnable =
    n:
    let
      modEval = builtins.tryEval (toCheck.${n});
    in
    if modEval.success then
      let
        enableEval = builtins.tryEval (modEval.value.enable or false);
      in
      if enableEval.success then enableEval.value else false
    else
      false;
  enabledNames = builtins.filter (n: getEnable n == true) (lib.lists.subtractLists blacklist names);
in
lib.attrsets.getAttrs enabledNames toCheck
```

### show programs/services which can be enabled

use `NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1`

```nix
let
  lib = pkgs.lib;
  toCheck = config.programs;
  toCompare = config.environment.systemPackages;
  # toCompare = config.home.packages;
  blacklist = [ "redis" ];
in
let
  names = builtins.attrNames toCheck;
  getEnable =
    n:
    let
      modEval = builtins.tryEval (toCheck.${n});
    in
    if modEval.success then
      let
        enableEval = builtins.tryEval (modEval.value.enable or null);
      in
      if enableEval.success then enableEval.value else false
    else
      false;
  enabledNames = builtins.filter (n: getEnable n == false) (lib.lists.subtractLists blacklist names);
in
let
  disabledSmth = lib.attrsets.getAttrs enabledNames toCheck;
  comparePackages =
    n:
    let
      modEval = builtins.tryEval (n.package or null);
    in
    if modEval.success then builtins.elem modEval.value toCompare else false;
in
lib.attrsets.filterAttrs (_: v: comparePackages v) disabledSmth
```

### show unfree (paid) apps

```nix
let
  allExplicitPkgs =
    config.environment.systemPackages
    ++ lib.concatMap (u: u.home.packages) (lib.attrValues config.home-manager.users)
    ++ lib.concatMap (u: u.packages) (lib.attrValues config.users.users)
    ++ config.fonts.packages
    ++ [ config.boot.kernelPackages.kernel ];

  isUnfree =
    pkg:
    let
      licenses = lib.toList (pkg.meta.license or [ ]);
    in
    lib.any (l: !(l.free or true)) licenses;
in
lib.unique (lib.filter isUnfree allExplicitPkgs)
```

## nix

### hash

```shell
nix hash file <filename>
nix-hash --type sha256 --sri <filename>

nix hash path <filename>
nix-hash --type sha256 --sri --flat <filename>

nix hash convert sha256:<full-sha256>
```

### resolve libs

```shell
ldd ./result/bin/executable | grep 'not found' | awk '{print $1}' | sort -u | xargs -I {} sh -c 'echo "Lib: {}"; nix-locate "{}"'
```

### don't stop build on hash mismatch (to mass-replace hashes)

```nix
let
  url = "";
  pkgs = import <nixpkgs> { };
in
(pkgs.fetchzip {
  inherit url;
  hash = "sha256-original+hash===============================" + "=";
  #? empty file (fetchurl)
  # hash = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=";
  #? empty path (fetchzip)
  # hash = "sha256-NOALhZKmrUZYUaRqZ0ZOB2EC/VEGymyzOi8VAJ0w1ZA=";

  nativeBuildInputs = [ pkgs.dpkg ];

  postFetch = ''
    echo
    echo "Calculating hash for $url"
    #? empty file (fetchurl)
    # ${pkgs.nix}/bin/nix --extra-experimental-features nix-command hash file "$out"
    #? empty path (fetchzip)
    ${pkgs.nix}/bin/nix --extra-experimental-features nix-command hash path "$out"
    echo sleep 9999
    echo
    sleep 9999
    # mv $out "$TMPDIR/unpack"
    # touch $out
  '';
}).outPath
```

let ... in approach

```nix
let
  fakefetchzip =
    _:
    fetchurl {
      inherit (_) url;
      # hash = "sha256-original+hash===============================" + "=";
      #? empty file (fetchurl)
      hash = "sha256-47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=";
      #? empty path (fetchzip)
      # hash = "sha256-NOALhZKmrUZYUaRqZ0ZOB2EC/VEGymyzOi8VAJ0w1ZA=";

      nativeBuildInputs = [ dpkg ];

      postFetch = ''
        echo
        echo "Calculating hash for $url"
        #? empty file (fetchurl)
        ${nix}/bin/nix --extra-experimental-features nix-command hash file "$out"
        #? empty path (fetchzip)
        # ${nix}/bin/nix --extra-experimental-features nix-command hash path "$out"
        echo sleep 9999
        echo
        sleep 9999
        # mv $out "$TMPDIR/unpack"
        # touch $out
      '';
    };
in fakefetchzip { url = "smth"; hash = "sha256-smth" }
```

### advanced nix-copy-closure

you can copy whole system closure to offline machine this way

```shell
PACKAGE_NAME=bat
nix-store --export $(nix-store --query --requisites $(realpath $(which $PACKAGE_NAME))) | zstd | pv > $PACKAGE_NAME.closure.zst

zstdcat $PACKAGE_NAME.closure.zst | nix-store --import
zstdcat $PACKAGE_NAME.closure.zst | sudo nix-store --import --no-require-sigs

zstdcat $PACKAGE_NAME.closure.zst | ssh admin "nix-store --import"
 REMOTE_PASSWORD=toor
#? /nix/var/nix/profiles/default/bin/nix-store
(echo $REMOTE_PASSWORD; zstdcat $PACKAGE_NAME.closure.zst) | ssh admin "sudo -S nix-store --import --no-require-sigs"
```

## python development

### [flake devShell](flake.nix)

```shell
nix develop ~/config/nix#python
# or
nix develop github:barsikus007/config?dir=nix#python
```

#### activate with [direnv](https://direnv.net/) `.envrc`

[vscode ext](https://marketplace.visualstudio.com/items?itemName=mkhl.direnv)

```shell
echo "use flake" > .envrc && direnv allow
```

#### x2nix

##### ? nix run github:nix-community/pip2nix -- generate -r requirements.txt

##### [pyproject2nix](https://wiki.nixos.org/wiki/Python#With_pyproject.toml)

###### [uv2nix](https://pyproject-nix.github.io/uv2nix/usage/hello-world.html)

uv2nix lets you fairly easily:

- use the UV package manager normally inside an impure shell
- use/set up an environment for projects using UV, which is quickly becoming the default python package manager
- build your package using nix

It's not perfect, you still need to make some edits to the uv2nix flake (e.g. when you want to change python version).

##### [dream2nix](https://dream2nix.dev/guides/pip/)

###### <https://github.com/DavHau/mach-nix>

<https://discourse.nixos.org/t/why-is-it-so-hard-to-use-a-python-package/19200/5>

Unlike poetry2nix & co, it uses a full database to map out pip packages, and is pretty good in just making things work without packaging them IME.

### [devenv](https://devenv.sh/getting-started/)

flake.nix with simplified nix syntax

```nix
{ pkgs, ... }:

{
  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };
}
```

#### [devbox](https://www.jetify.com/devbox/)

devenv analog with config in json

### other

#### [devshell (WIP)](https://numtide.github.io/devshell/getting_started.html)

#### [dev containers](https://containers.dev/)

- <https://dev.to/cmiles74/really-using-visual-studio-development-containers-561e>
- <https://habr.com/ru/companies/ruvds/articles/717110/>
