# config

- alias and function target is bash

## [Android](android/README.md)

## [Linux](linux/README.md)

## [Windows](windows/README.md)

## [Versus](versus/README.md)

## [Browser](browser/README.md)

## [Configs](configs/README.md)

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

#### Usage

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
pipx install uv
pipx install pdm
pipx install ruff
pipx install hatch
# hatch config
hatch config set dirs.env.virtual .venv
hatch config set template.licenses.headers false
hatch config set terminal.styles.spinner material
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

- Telegram > Settings > Advanced > Experimental settings
  - Add "View Profile"
  - Show Peer IDs in Profile
  - Send large photos
  - Enable webview inspecting
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

- move badapple gif and mp3 outsude of git (or genereate them idk)
- pycharm settings sync
- obs quick replay (import scenes)
- python
  - .editorconfig conf
  - alias pip='pip --require-virtualenv'
  - create python venv alias (current python installation pyenv.cfg windows)
  - [check every minor release](https://github.com/astral-sh/uv) (next is 0.3)
  - autoactivate venvs
    - zsh and virtualenvwrapper
  - uv install python
    - or proto
- terminal shit
  - batcat mouse rock-ssh
  - where which alias (and omit exe for windows)
- check all *.md sections with shellcheck
- IOS dualboot
  - <https://github.com/MatthewPierson/Divise>
  - <https://www.youtube.com/watch?v=_owhlPukE_A>
  - <https://dualbootfun.github.io/dualboot/>
- find browser sync bookmarks and history tool
- new software
  - GUI
    - <https://github.com/th-ch/youtube-music/releases/latest>
      - scoop install youtube-music
  - <https://github.com/isacikgoz/tldr>
    - tldr go ?
    - tldr -u
  - bat
    - [zsh '--help' alias](https://github.com/sharkdp/bat#highlighting---help-messages)
  - `mc` alternative
    - <https://github.com/ranger/ranger>
    - <https://github.com/sxyazi/yazi>
  - fish or zsh
    - windows (MSYS2) ?
    - WSL
    - LINUX
- config system
  - fast installer
    - <https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository/52269934#52269934>
  - save config folder somewhere to make it portable
    - use overlays to install this on linux?
  - links or copy
    - make changable
- nvim config
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
- vscode
  - export configs
    - layout
    - extensions
    - profiles
  - color logs
  - python -File activate envs
  - pycharm like run file
  - "python.analysis.autoImportCompletions": true
  - git tree view by default
  - ctrl+shift++ in terminal
- alias
  - grep config folder for cheatsheet
  - code=co
  - clear=cl
  - dcu not pull
  - dcup prod
  - aa = alias fzf
  - set-alias -name pn -value pnpm
  - wsl `find / -not -path '/mnt/*'`
  - `find / -not -path '/mnt/*' -name python -not -path '/home/*'`
  - git config core.editor=code -w -n
- dump from TG
  - corepack prepare & use wtf?
  - <https://github.com/jesseduffield/lazydocker/blob/master/docs/Config.md>
  - tmux fix updown buttons
  - filter nonmarket apps on pixel and backup list
    - pm list packages -i -3 | grep -v vending
  - eza
    - windows eza ~/pathes
    - eza --hyperlink | grep
