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
    ../../shared/options.nix
    ../../shared/nix.nix
    ../../modules/home-manager
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

      #? some common stuff that people expect to have
      #util-linux

      #tzdata
      #hostname
      #man
      #gnupg

      #gnutar
      #bzip2
      #gzip
      #xz
    ]
    ++ import ../../shared/lists { inherit pkgs; };
  environment.motd = "Welcome to Nix-on-Droid!";
  environment.sessionVariables = {
    SHELL = config.user.shell;
  };

  #? backup etc files instead of failing to activate generation if a file already exists in /etc
  # environment.etcBackupExtension = ".nodbackup";

  #? https://github.com/nix-community/nix-on-droid/blob/master/CHANGELOG.md
  system.stateVersion = "24.05";

  home-manager.config = {
    home.homeDirectory = lib.mkForce "/data/data/com.termux.nix/files/home";

    imports = [
      ../../home
      ../../home/shell/minimal.nix
    ];
    programs.zsh.shellAliases = {
      #? nix build --impure /data/data/com.termux.nix/files/home/config/nix#nixOnDroidConfigurations.default.activationPackage --print-out-paths
      nn = lib.mkForce "nix-on-droid switch --flake ${flakePath}";
      nr = lib.mkForce "nix repl --expr '(builtins.getFlake \"${flakePath}\").nixOnDroidConfigurations.default'";
    };
  };

  # TODO: stylix
  # terminal.colors = { };
  terminal.font = "${pkgs.cascadia-code}/share/fonts/truetype/CascadiaCodeNF-Regular.ttf";
  time.timeZone = "Europe/Moscow";
  user.shell = "${lib.getExe pkgs.zsh}";
  # user.userName = "nix-on-droid";
}
