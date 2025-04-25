{
  pkgs,
  unstable,
  ...
}:
with pkgs;
(import ./base.nix { inherit pkgs; })
++ [
  # other (specific cli tools)
  uv
  # aria2
  # tldr
  yt-dlp

  # GUI
  mpv
  vesktop
  unstable.ayugram-desktop
  nekoray
  neovide
  firefox
  keepassxc
  keepassxc-go
  # unstable.amneziawg-tools
  syncthingtray-qt6
  unstable.vscode-fhs
  unstable.isd
  ghostty
  helix

  # GUI unfree
  microsoft-edge
  obsidian

  unstable.graalvmPackages.graalvm-oracle
  prismlauncher
]
