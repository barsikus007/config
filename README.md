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
- .gitconfig TODO (may append if exist when applied)
  - autocrlf values
  - git config --global --add user.name "barsikus007"
  - git config --global --add user.email barsikus07@gmail.com

  - git config --global --add core.autocrlf input
  - git config --global --add core.ignorecase false

  - git config --global --add pull.rebase true

  - git config --global --add push.default current

  - git config --global --add merge.autoStash true

  - git config --global --add rebase.autostash true

  - git config --global init.defaultBranch master
- https://prismlauncher.org/download/
- ROG G14 AniMe
  - https://drive.google.com/drive/u/0/folders/1_FsWd2CAjAK13t82ZucTlNGabuI3laWF
  - https://blog.joshwalsh.me/asus-anime-matrix/
  - https://rog.asus.com/anime-matrix-pixel-editor/?device=DS-Animate#editor
- chmod +x executables in repo
- password manager
- https://violentmonkey.github.io
- add browser bookmarks
- make ru-en utf linux and windows locale
  - export LC_CTYPE=ru_RU.UTF-8
- new software
  - dos2unix
  - https://github.com/isacikgoz/tldr
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
  - https://github.com/th-ch/youtube-music/releases/latest
- terminal
  - !!!FISH!!!
    - windows (MSYS2) ?
    - WSL
    - LINUX
  - prompt
    - starship
      - fix custom git command for windows
      - design
      - fix character on exit
      - Administrator to root
      - command continue remove due to copy (?)
  - aliases
    - pwsh
    - bash
- config system
  - fast installer
  - https://stackoverflow.com/questions/600079/how-do-i-clone-a-subdirectory-only-of-a-git-repository/52269934#52269934
- nvim config
  - nvim alias
  - https://www.reddit.com/r/neovim/comments/oumljd/how_do_you_use_sudo_with_neovim_while_keeping_the/
  - https://nvchad.github.io/getting-started/setup
  - https://spacevim.org
  - https://jdhao.github.io/nvim-config/
  - https://www.youtube.com/watch?v=FW2X1CXrU1w
  - git clone https://github.com/NvChad/NvChad ~\.config\nvim --depth 1
  - https://gist.github.com/alexey-goloburdin/62d5b1b5ec19275d33497b7f3c0b6eec
  - https://github.com/alexey-goloburdin/nvim-config/blob/main/init.vim
- vscode export configs
