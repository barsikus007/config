{ lib, username, ... }:
#! 30Mb
{
  imports = [
    #! 150Kb
    ../shared/nix.nix
    ../modules/home-manager.nix
    #! 17Mb
    ../shared/nh.nix
  ];

  hardware.ksm.enable = true;

  # TODO: extract to locales.nix
  time.timeZone = lib.mkDefault "Europe/Moscow";
  i18n.defaultLocale = "C.UTF-8";
  i18n.extraLocaleSettings = {
    # LC_ALL = "C.UTF-8"; # This overrides all other LC_* settings.
    LC_CTYPE = "en_US.UTF-8";
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "en_GB.UTF-8";
    LC_COLLATE = "en_US.UTF-8";
  };
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:win_space_toggle";
    # ,grp:lalt_lshift_toggle
    # ,ctrl:nocaps
  };
  console.useXkbConfig = true;

  #? Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      (lib.strings.removeSuffix "\n" (
        builtins.readFile (
          builtins.fetchurl {
            url = "https://github.com/barsikus007.keys";
            sha256 = "sha256-Tnf/WxeYOikI9i5l4e0ABDk33I5z04BJFApJpUplNi0=";
          }
        )
      ))
    ];
  };
  nix.settings.trusted-users = [ username ];

  services.openssh = {
    enable = true;
    ports = lib.mkDefault [ 2222 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  #! 80Kb
  programs.nix-ld.enable = true;
}
