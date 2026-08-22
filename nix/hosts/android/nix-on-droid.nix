{
  lib,
  pkgs,
  flakePath,
  ...
}:
#? https://nix-community.github.io/nix-on-droid/nix-on-droid-options.html#sec-options
let
  zsh_bin = lib.getExe pkgs.zsh;
in
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
    [
      (pkgs.writeShellScriptBin "ping" ''
        /android/system/bin/linker64 /android/system/bin/ping "$@"
      '')

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
  environment.sessionVariables.SHELL = zsh_bin;

  #? backup etc files instead of failing to activate generation if a file already exists in /etc
  # environment.etcBackupExtension = ".nodbackup";

  #? https://github.com/nix-community/nix-on-droid/blob/master/CHANGELOG.md
  system.stateVersion = "24.05";

  home-manager.config = {
    imports = [
      ../../home
      ../../home/shell/minimal.nix
    ];
    programs.zsh.shellAliases = {
      #? sh $(nom build --impure $HOME/config/nix#nixOnDroidConfigurations.default.activationPackage --no-link --print-out-paths)/activate
      nn = lib.mkForce "nix-on-droid switch --flake ${flakePath}";
      nnn = "sh $(nom build --impure ${flakePath}#nixOnDroidConfigurations.default.activationPackage --no-link --print-out-paths)/activate";
      nr = lib.mkForce "nix repl --expr '(builtins.getFlake \"${flakePath}\").nixOnDroidConfigurations.default'";
    };
  };

  # TODO: stylix
  # terminal.colors = { };
  terminal.font = "${pkgs.cascadia-code}/share/fonts/truetype/CascadiaCodeNF-Regular.ttf";
  time.timeZone = "Europe/Moscow";
  #! proot-termux unstable-2026-02-20 passes fds that fail isatty, so zsh stays
  #! non-interactive and skips .zshrc; the pty itself is still reachable via /dev/tty
  user.shell = lib.getExe (
    pkgs.writeShellScriptBin "login-shell" ''
      if [ -t 0 ] && [ -t 1 ]; then
        exec ${zsh_bin} --login
      fi
      if (: < /dev/tty) 2> /dev/null; then
        exec ${zsh_bin} --login < /dev/tty > /dev/tty 2> /dev/tty
      fi
      #? no pty at all, force interactive so .zshrc still loads; zle stays off
      exec ${zsh_bin} --login --interactive
    ''
  );
  # user.userName = "nix-on-droid";
}
