{
  lib,
  pkgs,
  inputs,
  config,
  flakePath,
  ...
}:
#? https://nix-community.github.io/nix-on-droid/nix-on-droid-options.html#sec-options
{
  # modules = [
  #   #! ./shared/nix.nix
  # ];
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
    '';
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };
    substituters = [
      "https://cache.nixos.org"
      # "https://nixos-cache-proxy.cofob.dev" # ? cloudflare mirror, uses original keys

      "https://nix-community.cachix.org"
    ];
    trustedPublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  android-integration.am.enable = true;
  android-integration.termux-setup-storage.enable = true;
  android-integration.termux-open.enable = true;
  android-integration.termux-open-url.enable = true;
  android-integration.termux-reload-settings.enable = true;
  android-integration.termux-wake-lock.enable = true;
  android-integration.termux-wake-unlock.enable = true;
  android-integration.xdg-open.enable = true;
  # android-integration.unsupported.enable = true;

  # Simply install just the packages
  environment.packages =
    with pkgs;
    [
      zsh
      android-tools
      dig

      # Some common stuff that people expect to have
      #util-linux

      #tzdata
      #hostname
      #man
      #gnupg

      #gnutar
      #bzip2
      #gzip
      #xz
      #zip
      #unzip
    ]
    ++ import ./shared/lists/00_essential.nix { inherit pkgs; }
    ++ import ./shared/lists/01_base.nix { inherit pkgs; }
    ++ import ./shared/lists/02_add.nix { inherit pkgs; };
  environment.motd = "Welcome to Nix-on-Droid!";
  environment.sessionVariables = {
    SHELL = config.user.shell;
  };

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  # environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # backupFileExtension = "hm-bak";
    config = {
      # Read the changelog before changing this value
      home = {
        stateVersion = lib.mkForce "25.11";
        homeDirectory = lib.mkForce "/data/data/com.termux.nix/files/home";
      };

      imports = [
        ./home
        ./home/shell/minimal.nix
      ];
      programs.zsh.shellAliases = {
        nn = lib.mkForce "nix-on-droid switch --flake ${flakePath}";
        nr = lib.mkForce "nix repl --expr '(builtins.getFlake \"${flakePath}\").nixOnDroidConfigurations.default'";
      };
    };
  };

  # TODO: stylix
  # terminal.colors = { };
  terminal.font = with pkgs; "${cascadia-code}/share/fonts/truetype/CascadiaCodeNF-Regular.ttf";
  time.timeZone = "Europe/Moscow";
  user.shell = "${lib.getExe pkgs.zsh}";
  # user.userName = "nix-on-droid";
}
