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
  microsoft-edge
  firefox
  keepassxc
  keepassxc-go
  obsidian
  # unstable.amneziawg-tools
  syncthingtray-qt6
  unstable.vscode-fhs
  unstable.isd
  ghostty
  helix

  # TODO: will it be available due to steam pkg?
  steam-run

  unstable.graalvmPackages.graalvm-oracle
  prismlauncher
]
