# config

## [NixOS](./nix/README.md)

### [packages](./nix/flake.nix)

```shell
#? generic with system nixpkgs usaage
nix run --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#<packageName>'
#? kompas on non-NixOS
nix --extra-experimental-features "nix-command flakes" run --impure --override-input nixpkgs nixpkgs 'github:nix-community/nixGL' -- env NIXPKGS_ALLOW_UNFREE=1 nix run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#kompas3d-fhs'
#? rm ~/.config/ascon/KOMPAS-3D/24/{recent_files.xml,KOMPAS.kit.config}
#? launch on computer with enough system parts (remote) lol
sudo NIXPKGS_ALLOW_UNFREE=1 nix --extra-experimental-features "nix-command flakes" run --impure --override-input nixpkgs nixpkgs 'github:barsikus007/config?dir=nix#grdcontrol'
#? launch on computer with kompas (client)
socat TCP-LISTEN:3189,bind=127.0.0.1,fork TCP:<remote_ip>:3189
```

#### [OpenWrt Image](./nix/packages/openwrt/xiaomi_ax3600.nix)

##### TODO

- [wiki #1](https://wiki.nixos.org/wiki/Networking_working_group)
  - <https://github.com/disassembler/network/blob/master/nixos/portal/configuration.nix>
- [wiki #2](https://wiki.nixos.org/wiki/OpenWrt)
  - UCI declarative
    - <https://github.com/MakiseKurisu/dewclaw>
- [disable IPV6](https://3os.org/infrastructure/openwrt/disable-ipv6/)

## [Android](./android/README.md)

## [Linux](./linux/README.md)

## [Windows](./windows/README.md)

## [Versus](./versus/README.md)

## [Browser](./browser/README.md)

## [Archive](./аrchive/README.md)

## Cross-platform

### [Git config (`~/.config/git/config`)](https://git-scm.com/docs/git-config)

[nix code to fill](nix/home/default.nix#:~:text=%23%20%7D;-,userName):

```shell
mkdir -p ~/.config/git/
nix eval --impure --raw --expr '
  with import <nixpkgs> {};
  pkgs.lib.generators.toGitINI
    ((builtins.getFlake "github:barsikus007/config?dir=nix")
      .homeConfigurations.ogurez.config.programs.git.iniContent)
' > ~/.config/git/config
```

#### [Signing](https://docs.github.com/en/authentication/managing-commit-signature-verification/displaying-verification-statuses-for-all-of-your-commits)

1. [Upload key](https://github.com/settings/ssh/new)
2. Configure git (code above fills values)

### [proto](https://moonrepo.dev/proto)

#### Usage

```shell
# TODO https://moonrepo.dev/docs/proto/commands/completions
proto install go
# then clean ~/.bashrc
proto install node lts
proto install pnpm
proto install bun
# TODO proto install rust -- --profile minimal
```

#### Install

##### Linux

```shell
curl -fsSL https://moonrepo.dev/install/proto.sh | PROTO_INSTALL_DIR=$XDG_CONFIG_HOME/proto/bin bash -s -- --no-profile
rm -rf ~/.proto/
```

##### Windows

```powershell
$env:PROTO_INSTALL_DIR = "~\.config\proto\bin"
# irm https://moonrepo.dev/install/proto.ps1 | iex
& ([scriptblock]::Create((irm https://moonrepo.dev/install/proto.ps1))) --no-profile
Remove-Item -Recurse ~\.proto\
# TODO add proto to scoop
```

### Python

```shell
python3 -m pip install --upgrade pip setuptools wheel
```

#### uv

```shell
uv python install
uv python install --preview
# uv python install 3.10 3.11 3.12 3.13t pypy
# uv python install --preview 3.10 3.11 3.12 3.13t pypy3.11
```

[TODO - python available globally](https://docs.astral.sh/uv/guides/install-python/#getting-started)

```shell
# linux
curl -LsSf https://astral.sh/uv/install.sh | sh
# windows
scoop install uv
# powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

uv tool --version  # 0.6.14
# uv tool install isd
# uv tool install ruff
# uv tool install hatch
# uv tool install pgcli
# uv tool install litecli
# uv tool install --with ipython ptpython
# uv tool install anicli-ru
# uv tool install anicli-ru --upgrade-package anicli-api
uv tool upgrade --all
```

#### hatch

```shell
hatch config set dirs.env.virtual .venv
hatch config set template.licenses.headers false
hatch config set terminal.styles.spinner material
# TODO or use uv for python projects
# https://hatch.pypa.io/latest/how-to/environment/select-installer/#enabling-uv
```

##### release schedule

```shell
hatch test -ac
hatch version micro
hatch build
hatch publish
```

###### tag based

```shell
hatch test -ac
hatch version micro
git commit -am "release: $(hatch version)"
git tag -a $(hatch version) -m
git push origin --follow-tags
```

#### [hatch sync env](https://github.com/pypa/hatch/discussions/594#discussioncomment-4377827)

```shell
hatch run true
```

### Other

- Telegram > Settings
  - Notifications and Sound
    - Calls > Accept calls on this device
    - Badge counter > !1,!3
  - Advanced
    - Automatic media download > * > !Files
    - Window title bar > Use * window frame
    - Spell checker >
    - Experimental settings
      - Add "View Profile"
      - Show Peer IDs in Profile
      - Send large photos
      - Enable webview inspecting

### TODO

- meta
  - Syncthing Tray/service setup info (isn't declarative)
  - check all `*.md` and `*.nix` code sections with `shellcheck`
  - clone single dir
    - <https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository/52269934#52269934>
  - info about CH340

### Archive

- Docker Desktop Extensions
  - Ddosify
  - Disk usage
- PyCharm
  - Settings Sync
  - Terminal | pwsh.exe -NoLogo
  - File > Settings > Appearance & Behavior > File Colors >> Non-Project Files -> Use in editor tabs
- YtMusic
  - adblocker
  - blur-nav-bar
  - lyrics-genius
  - navigation
  - picture-in-picture
  - precise-volume
  - shortcuts
  - sponsorblock
  - video-toggle
- IOS dualboot
  - <https://github.com/MatthewPierson/Divise>
  - <https://www.youtube.com/watch?v=_owhlPukE_A>
  - <https://dualbootfun.github.io/dualboot/>
