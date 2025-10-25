# [cheatsheet](./README.md)

## nixpkgs

- [index](https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix)
  - `code $(nix eval -f '<nixpkgs>' path)/pkgs/top-level/all-packages.nix`
- [phases order](https://nixos.org/manual/nixpkgs/stable/#sec-stdenv-phases)

### misc

- ventoy: `NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_INSECURE=1 nix-shell -p ventoy-full-qt`
  - `sudo ventoy-gui /dev/...`
  - `sudo ventoy-plugson /dev/...`

## nixos-rebuild

```bash
# no internet
nh os switch /home/ogurez/config/nix -- --option substitute false
```

## nix

### hash

```bash
nix hash file <filename>
nix-hash --type sha256 --sri <filename>

nix hash path <filename>
nix-hash --type sha256 --sri --flat <filename>
```

## resolve libs

```bash
ldd ./result/bin/executable | grep 'not found' | awk '{print $1}' | sort -u | xargs -I {} sh -c 'echo "Lib: {}"; nix-locate "{}"'
```

## don't stop build on hash mismatch (to mass-replace hashes)

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

## python development

[direnv](https://devenv.sh/automatic-shell-activation/)

### [flake devShell](flake.nix)

```shell
nix develop ~/config/nix#python
# or
nix develop github:barsikus007/config?dir=nix#python
```

#### ? nix run github:nix-community/pip2nix -- generate -r requirements.txt

### [devenv](https://devenv.sh/getting-started/)

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

### [devbox](https://www.jetify.com/devbox/)

### [uv2nix](https://pyproject-nix.github.io/uv2nix/usage/hello-world.html)

uv2nix lets you fairly easily:

- use the UV package manager normally inside an impure shell
- use/set up an environment for projects using UV, which is quickly becoming the default python package manager
- build your package using nix

It's not perfect, you still need to make some edits to the uv2nix flake (e.g. when you want to change python version).

### [pyproject2nix](https://wiki.nixos.org/wiki/Python#With_pyproject.toml)

### [dream2nix](https://dream2nix.dev/guides/pip/)

#### <https://github.com/DavHau/mach-nix>
<https://discourse.nixos.org/t/why-is-it-so-hard-to-use-a-python-package/19200/5>

Unlike poetry2nix & co, it uses a full database to map out pip packages, and is pretty good in just making things work without packaging them IME.

### last resort python

#### [devshell](https://numtide.github.io/devshell/getting_started.html)

#### [python issue ?](https://github.com/numtide/devshell/issues/172#issuecomment-1094675420)

#### [dev containers](https://containers.dev/)

#### ld fix?

```nix
  programs.nix-ld = {
    enable = true;
    #Include libstdc++ in the nix-ld profile
    libraries = [
      pkgs.stdenv.cc.cc
      pkgs.zlib
      pkgs.fuse3
      pkgs.icu
      pkgs.nss
      pkgs.openssl
      pkgs.curl
      pkgs.expat
      pkgs.xorg.libX11
      pkgs.vulkan-headers
      pkgs.vulkan-loader
      pkgs.vulkan-tools
    ];
  };
  environment.systemPackages = [

    (pkgs.writeShellScriptBin "python" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${pkgs.python3}/bin/python "$@"
    '')
  ];
```
