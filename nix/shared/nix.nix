{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  nix.package = pkgs.nix;
  nix.channel.enable = false;
  nix.registry = {
    nixpkgs.flake = inputs.nixpkgs;
  };
  nix.settings = {
    auto-optimise-store = true;
    use-xdg-base-directories = true;
    experimental-features = [
      "nix-command"
      "flakes"
      "pipe-operators"
    ];

    stalled-download-timeout = 4;
    connect-timeout = 4;

    substituters = lib.mkAfter [
      "https://cache.nixos.kz"
      "https://mirror.yandex.ru/nixos"
      # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # REF: https://github.com/dramforever/mirror-web/blob/d7e263d4fe9a9e3078f819468cec18e1c11cf832/_posts/help/2019-02-17-nix.md
      "https://ncproxy.vizqq.cc"
      "https://nixos-cache-proxy.cofob.dev" # ? cloudflare mirror, uses original keys
      "https://nixos-cache-proxy.sweetdogs.ru"

      "https://nix-community.cachix.org"

      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = lib.mkAfter[
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };
}
