{
  _class,
  lib,
  pkgs,
  self,
  config,
  inputs,
  ...
}:
let
  inherit ((import ../flake.nix)) nixConfig;
  nix = {
    package = lib.mkDefault pkgs.nix;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      # master.flake = inputs.nixpkgs-master;
    };
    settings = {
      warn-dirty = false;
      auto-optimise-store = true;
      use-xdg-base-directories = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      stalled-download-timeout = 3;
      connect-timeout = 3;

      substituters = [
        #? https://cache.nixos.org has priority 40
        #? I use 39 for faster location mirrors; 41 for mirrors; 42 for useful cachix;
        "https://mirror.yandex.ru/nixos?priority=39" # ! я русский
        # "https://cache.nixos.kz?priority=41" # ? returned a lot "Timeout was reached" errors
        # "https://ncproxy.vizqq.cc?priority=41" # ? returned a lot "Timeout was reached" errors when I tried to install nix on nas
        # "https://nixos-cache-proxy.cofob.dev?priority=41" # ? cloudflare mirror, uses original keys # ? returned a lot "Timeout was reached" errors when I tried to install nix on nas
      ];
      extra-substituters = lib.mkBefore nixConfig.extra-substituters;
      inherit (nixConfig) extra-trusted-public-keys;
    };
  };

  nixpkgs.overlays = [
    (_final: _prev: {
      flakePackages = lib.attrsets.mergeAttrsList [
        self.legacyPackages.${pkgs.stdenv.hostPlatform.system}
        self.packages.${pkgs.stdenv.hostPlatform.system}
      ];
    })
  ];
in
if (_class == "nixos") then
  lib.attrsets.recursiveUpdate { inherit nix; } {
    environment.etc."nixpkgs".source = pkgs.path;
    nix = {
      channel.enable = false;
      settings = {
        #? in zfs we trust even more
        fsync-metadata = config.boot.isContainer || ((config.fileSystems."/".fsType or "") != "zfs");
      };
    };
    inherit nixpkgs;
  }
else if (_class == "nixOnDroid") then
  {
    nix = {
      inherit (nix) registry;
      extraOptions = ''
        experimental-features = ${builtins.concatStringsSep " " nix.settings.experimental-features}
      '';
      nixPath = [ "nixpkgs=flake:nixpkgs" ];
      substituters = nix.settings.substituters ++ nix.settings.extra-substituters;
      trustedPublicKeys = nix.settings.trusted-public-keys ++ nix.settings.extra-trusted-public-keys;
    };
  }
else if (_class == "homeManager") then
  {
    inherit nix nixpkgs;
  }
else
  throw "shared/nix.nix: unknown _class: ${_class}"
