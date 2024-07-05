# config

- alias and function target is bash

## [Versus](versus/README.md)

## [Browser](browser/README.md)

## [Configs](configs/README.md)

## [Android](android/README.md)

## [Linux](linux/README.md)

## [Windows](windows/README.md)

## Cross-platform

### [Git config (`~/.gitconfig`)](https://git-scm.com/docs/git-config)

```bash
git config --global user.name barsikus007
git config --global user.email barsikus07@gmail.com

git config --global core.editor "code --wait"
git config --global core.autocrlf input
git config --global core.ignoreCase false

git config --global init.defaultBranch master

git config --global push.default current

git config --global pull.rebase true

git config --global merge.autoStash true

git config --global rebase.autoStash true
```

#### [Signing](https://docs.github.com/en/authentication/managing-commit-signature-verification/displaying-verification-statuses-for-all-of-your-commits)

[Upload key](https://github.com/settings/ssh/new)

```bash
git config --global user.signingKey ~/.ssh/id_ed25519.pub
git config --global commit.gpgSign true
git config --global gpg.format ssh
```

### [proto](https://moonrepo.dev/proto)

#### Use

```bash
# TODO https://moonrepo.dev/docs/proto/commands/completions
proto install go
proto install node lts
proto install pnpm
# TODO bun windows
# scoop bucket add versions
# scoop install bun-canary
proto install bun
# TODO test tools
# proto install python
# proto install rust
```

#### Install

##### Linux

```bash
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

#### pipx

```bash
# install
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install --user pipx-in-pipx
# or
# use apt scoop or etc PM
python3 -m pipx ensurepath
# TODO rm /mnt/c/users/admin/appdata/roaming/python/python312/scripts/register-python-argcomplete
pipx install hatch
pipx install poetry
# hatch config
hatch config set dirs.env.virtual .venv
hatch config set template.licenses.headers false
hatch config set terminal.styles.spinner material
# poetry config
# TODO
pipx install ptpython
# pipx inject ptpython ipython
pipx install git+https://github.com/vypivshiy/ani-cli-ru@dev
pipx upgrade-all
```

#### hatch release schedule

```bash
hatch run test:cov
hatch version micro
hatch build
hatch publish
```

#### [hatch sync env](https://github.com/pypa/hatch/discussions/594#discussioncomment-4377827)

```bash
hatch run true
```

### Docker Desktop Extensions

- Ddosify
- Disk usage

### Other

- Telegram > Settings > Advanced > Experimental settings > Send large photos
- Discord
  - Vencord
    - Install
      - `winget install Discord.Discord`
      - `git clone https://github.com/philhk/Vencord`
      - `pnpm i`
      - `pnpm build`
      - `pnpm inject`
      - Import `configs/vencord-settings-backup.json`
    - Update
      - `cd Vencord`
      - `git pull`
      - `pnpm build`
      - Refresh client
    - [Vesktop](https://github.com/Vencord/Vesktop/releases/latest)
      - [scoop](https://github.com/ScoopInstaller/Extras/pull/11935)
- PyCharm
  - terminal pwsh.exe -NoLogo
  - File | Settings | Appearance & Behavior | File Colors || Non-Project Files -> Use in editor tabs
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

### TODO

- pycharm settings sync
- obs quick replay (import scenes)
- python
  - black conf
  - .editorconfig conf
  - alias pip='pip --require-virtualenv'
  - create python venv alias (current python installation pyenv.cfg windows)
  - piptool scoop??
  - [check every minor release](https://github.com/astral-sh/uv) (next is 0.2)
  - alias to ptpython
  - linux alternative to py
  - autoactivate venvs
- terminal shit
  - batcat mouse rock-ssh
  - where which alias (and omit exe for windows)
- check all *.md sections with shellcheck
- IOS dualboot
  - <https://github.com/MatthewPierson/Divise>
  - <https://www.youtube.com/watch?v=_owhlPukE_A>
  - <https://dualbootfun.github.io/dualboot/>
- chmod +x executables in repo
- find tool
  - browser sync bookmarks and history tool
- new software
  - GUI
    - <https://prismlauncher.org/download/>
    - <https://github.com/th-ch/youtube-music/releases/latest>
      - scoop install youtube-music
  - <https://github.com/isacikgoz/tldr>
    - tldr go ?
    - tldr -u
  - bat
    - mkdir -p ~/.local/bin
    - ln -s /usr/bin/batcat ~/.local/bin/bat
  - `mc` alternative
    - <https://github.com/ranger/ranger>
    - <https://github.com/sxyazi/yazi>
  - terminal
    - !!!FISH!!!
      - windows (MSYS2) ?
      - WSL
      - LINUX
    - prompt
      - starship
        - design
        - fix character on exit
        - Administrator to root
        - command continue remove due to copy (?)
    - aliases
      - pwsh
      - bash
- config system
  - fast installer
    - <https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository/52269934#52269934>
  - save config folder somewhere to make it portable
    - use overlays to install this on linux?
  - links or copy
    - make changable

- nvim config
  - nvim alias
  - <https://www.reddit.com/r/neovim/comments/oumljd/how_do_you_use_sudo_with_neovim_while_keeping_the/>
  - IDE
    - <https://nvchad.com/docs/quickstart/install>
    - <https://spacevim.org>
    - <https://jdhao.github.io/nvim-config/>
    - <https://github.com/LazyVim/LazyVim>
  - example
    - <https://www.youtube.com/watch?v=FW2X1CXrU1w>
    - <https://gist.github.com/alexey-goloburdin/62d5b1b5ec19275d33497b7f3c0b6eec>
    - <https://github.com/alexey-goloburdin/nvim-config/blob/main/init.vim>
  - plugin system
    - <https://github.com/folke/lazy.nvim>
    - <https://github.com/junegunn/vim-plug>
- vscode export configs
  - layout
  - extensions
  - profiles
