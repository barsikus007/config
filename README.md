# config

## [Android](android/README.md)

## [Linux](linux/README.md)

## Cross-platform

### Python

```bash
# pipx install
python3 -m pip install --upgrade pip setuptools wheel
python3 -m pip install --user pipx
python3 -m pipx ensurepath
# TODO rm /mnt/c/users/admin/appdata/roaming/python/python311/scripts/register-python-argcomplete
# hatch install
pipx install hatch
# poetry install
pipx install poetry
# hatch config
hatch config set dirs.env.virtual .venv
hatch config set template.licenses.headers false
hatch config set terminal.styles.spinner material
# poetry config
# TODO
```

## TODO

- Vencord
  - `git clone https://github.com/philhk/Vencord`
  - `pnpm i`
  - `pnpm build`
  - `pnpm inject`
  - Import `configs/vencord-settings-backup.json`
- linux `zgrep -E "Commandline: apt(|-get)" /var/log/apt/history.log*`
- create python venv alias (current python installation pyenv.cfg windows)
- batcat mouse rock-ssh
- piptool scoop??
- chromium flag for faster downloads
  - edge://flags/#enable-parallel-downloading
  - opera://flags/#enable-parallel-downloading
- <https://volta.sh/>
- mpv config
- TOOL TODO ! (install windows soft with auto update from winget (think about config sync of that apps))
- ask scoop maintaners about FAQ about tools with autoupdate
- mkcd alias (mkdir + cd)
- PyCharm
  - terminal pwsh.exe -NoLogo
  - File | Settings | Appearance & Behavior | File Colors || Non-Project Files -> Use in editor tabs
- IOS dualboot
  - <https://github.com/MatthewPierson/Divise>
  - <https://www.youtube.com/watch?v=_owhlPukE_A>
  - <https://dualbootfun.github.io/dualboot/>
- where which alias (and omit exe for windows)
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
- .gitconfig
  - autocrlf values
  - `git config --global user.name "barsikus007"`
  - `git config --global user.email barsikus07@gmail.com`

  - `git config --global core.editor "code --wait"`
  - `git config --global core.autocrlf input`
  - `git config --global core.ignoreCase false`

  - `git config --global init.defaultBranch master`

  - `git config --global push.default current`

  - `git config --global pull.rebase true`

  - `git config --global merge.autoStash true`

  - `git config --global rebase.autoStash true`

- <https://prismlauncher.org/download/>
- chmod +x executables in repo
- browser
  - password manager
  - <https://violentmonkey.github.io>
  - sync bookmarks
- new software
  - dos2unix
  - <https://github.com/isacikgoz/tldr>
    - tldr go ?
    - tldr -u
  - bat
    - mkdir -p ~/.local/bin
    - ln -s /usr/bin/batcat ~/.local/bin/bat
    -
    - alias to cat
  - duf
  - ncdu
  - btop
  - btop-lhm windows
  - <https://github.com/th-ch/youtube-music/releases/latest>
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
- nvim config
  - nvim alias
  - <https://www.reddit.com/r/neovim/comments/oumljd/how_do_you_use_sudo_with_neovim_while_keeping_the/>
  - <https://nvchad.github.io/getting-started/setup>
  - <https://spacevim.org>
  - <https://jdhao.github.io/nvim-config/>
  - <https://www.youtube.com/watch?v=FW2X1CXrU1w>
  - git clone <https://github.com/NvChad/NvChad> ~\.config\nvim --depth 1
  - <https://gist.github.com/alexey-goloburdin/62d5b1b5ec19275d33497b7f3c0b6eec>
  - <https://github.com/alexey-goloburdin/nvim-config/blob/main/init.vim>
- vscode export configs
