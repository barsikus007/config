{ pkgs, ... }:
{
  #? https://nix-community.github.io/nix-on-droid/nix-on-droid-options.html#sec-options
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
  environment.packages = with pkgs; [
    neovim
    git

    # Some common stuff that people expect to have
    #procps
    #killall
    #diffutils
    #findutils
    #utillinux
    #tzdata
    #hostname
    #man
    #gnugrep
    #gnupg
    #gnused
    #gnutar
    #bzip2
    #gzip
    #xz
    #zip
    #unzip
  ];
  # environment.sessionVariables = { };

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  # environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  # system.stateVersion = "24.05";
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # backupFileExtension = "hm-bak";
    config = {
      # Read the changelog before changing this value
      # home.stateVersion = "24.05";

      modules = [

      ];
    };
  };
  # terminal.colors;
  terminal.font = with pkgs; "${cascadia-code}/share/fonts/truetype/CascadiaCodeNF-Regular.ttf";
  # terminal.font = with pkgs; "${cascadia-code}/share/fonts/opentype/CascadiaCodeNF-Regular.otf";
  # time.timeZone = "Europe/Moscow";
  # user.shell = "${pkgs.zsh}/bin/zsh"
  # user.userName = "nix-on-droid";
}
