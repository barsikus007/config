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
# then clean ~/.bashrc
proto install node lts
proto install pnpm
proto install bun
# TODO proto install rust -- --profile minimal
```

#### Install

##### Linux

```bash
curl -fsSL https://moonrepo.dev/install/proto.sh | PROTO_INSTALL_DIR=$XDG_CONFIG_HOME/proto/bin bash -s -- --no-profile
rm -rf ~/.proto/
```

*
##### Windows

```powershell
$env:PROTO_INSTALL_DIR = "~\.config\proto\bin"
# irm https://moonrepo.dev/install/proto.ps1 | iex
& ([scriptblock]::Create((irm https://moonrepo.dev/install/proto.ps1))) --no-profile
Remove-Item -Recurse ~\.proto\
# TODO add proto to scoop
```

### Python

```bash
python3 -m pip install --upgrade pip setuptools wheel
```

#### uv

```bash
uv python install
uv python install --preview
# uv python install 3.10 3.11 3.12 3.13t pypy
# uv python install --preview 3.10 3.11 3.12 3.13t pypy3.11
```

[TODO - python available globally](https://docs.astral.sh/uv/guides/install-python/#getting-started)

```bash
# linux
curl -LsSf https://astral.sh/uv/install.sh | sh
# windows
scoop install uv
# powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

uv tool --version  # 0.5.6
uv tool install ruff
uv tool install hatch
uv tool install --with ipython ptpython
uv tool install anicli-ru
# uv tool install anicli-ru --upgrade-package anicli-api
uv tool upgrade --all
```

#### hatch

```bash
hatch config set dirs.env.virtual .venv
hatch config set template.licenses.headers false
hatch config set terminal.styles.spinner material
# TODO or use uv for python projects
# https://hatch.pypa.io/latest/how-to/environment/select-installer/#enabling-uv
```

##### release schedule

```bash
hatch run test:cov
hatch version micro
hatch build
hatch publish
```

###### tag based

```bash
hatch run test:cov
hatch version micro
git commit -am "release: $(hatch version)"
git tag -a $(hatch version) -m
git push origin --follow-tags
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
    - <https://github.com/denisidoro/navi>
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
  - clone single dir
    - <https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository/52269934#52269934>
  - know overlays
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
  - eza
    - windows eza ~/pathes
    - eza --hyperlink | grep
