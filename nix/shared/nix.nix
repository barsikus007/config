{
  _class,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  nix = {
    package = lib.mkDefault pkgs.nix;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      # master.flake = inputs.nixpkgs-master;
    };
    settings = {
      auto-optimise-store = true;
      use-xdg-base-directories = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];

      stalled-download-timeout = 3;
      connect-timeout = 3;

      substituters = lib.mkBefore [
        "https://cache.nixos.org"
        # "https://cache.nixos.kz" # ? returned a lot "Timeout was reached" errors
        "https://mirror.yandex.ru/nixos"
        # "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" # ? https://github.com/dramforever/mirror-web/blob/d7e263d4fe9a9e3078f819468cec18e1c11cf832/_posts/help/2019-02-17-nix.md
        "https://ncproxy.vizqq.cc"
        "https://nixos-cache-proxy.cofob.dev" # ? cloudflare mirror, uses original keys
        # "https://nixos-cache-proxy.sweetdogs.ru" # ? seems died

        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = lib.mkBefore [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
in
if (_class == "nixos") then
  {
    environment.etc."nixpkgs".source = pkgs.path;
    nix = {
      channel.enable = false;
    }
    // nix;
  }
else if (_class == "nixOnDroid") then
  {
    nix = {
      inherit (nix) registry;
      inherit (nix.settings) substituters;
      extraOptions = ''
        experimental-features = ${builtins.concatStringsSep " " nix.settings.experimental-features}
      '';
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
      trustedPublicKeys = nix.settings.trusted-public-keys;
    };
  }
else
  #? home-manager
  {
    inherit nix;
  }
