{
  lib,
  pkgs,
  config,
  flakePath,
  ...
}:
#? https://nix-community.github.io/nix-on-droid/nix-on-droid-options.html#sec-options
{
  imports = [
    ./shared/nix.nix
  ];
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
    let
      ping = pkgs.writeShellScriptBin "ping" ''
        /android/system/bin/linker64 /android/system/bin/ping "$@"
      '';
    in
    [
      ping

      zsh
      android-tools
      dig

      yt-dlp

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
    ++ import ./shared/lists { inherit pkgs; };
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
    backupFileExtension = "hmbackup";
    config = {
      # Read the changelog before changing this value
      home = {
        stateVersion = lib.mkForce "26.05";
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
