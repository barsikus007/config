{
  config,
  lib,
  pkgs,
  username,
  flakePath,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  # Optionally
  i18n.extraLocaleSettings = {
    # LC_ALL = "C.UTF-8"; # This overrides all other LC_* settings.
    LC_CTYPE = "en_US.UTF8";
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8"; # en_US.UTF-8
    LC_TIME = "C.UTF-8";
    LC_COLLATE = "ru_RU.UTF-8"; # en_US.UTF-8
    LC_IDENTIFICATION = "ru_RU.UTF-8"; # en_US.UTF-8
  };

  fonts.packages = with pkgs; [
    cascadia-code
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  users.defaultUserShell = pkgs.zsh;
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  programs.zsh.enable = true;
  programs.fish = {
    enable = true;
    useBabelfish = true;
  };
  # users.users.
  # isNormalUser = true;
  # extraGroups = [ "wheel" "networkmanager" "docker" ];
  # hashedPassword = "hashedPassword";

  programs.nh = {
    enable = true;
    clean.enable = true;
    # clean.dates = "weekly";
    clean.dates = "daily";
    clean.extraArgs = "--keep 5 --keep-since 4d";
    flake = flakePath;
  };
}
