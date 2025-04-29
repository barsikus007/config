{
  pkgs,
  unstable,
  ...
}:
with pkgs;
(import ./base.nix { inherit pkgs; })
++ [
  # other (specific cli tools)
  # aria2
  # tldr
  yt-dlp

  # CLI python
  unstable.uv
  hatch

  # GUI
  mpv
  nekoray
  neovide
  firefox
  ghostty
  unstable.vscode-fhs
  keepassxc
  qbittorrent

  # GUI social
  vesktop
  unstable.ayugram-desktop
  element-desktop

  # https://www.reddit.com/r/software/comments/t5n3cm/everything_for_linux/
  fsearch

  # GUI unfree
  microsoft-edge
  obsidian
]
