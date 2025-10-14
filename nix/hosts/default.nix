{
  pkgs,
  username,
  flakePath,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    home-manager
  ];

  environment.variables = rec {
    EDITOR = "nvim";
    VISUAL = EDITOR;
  };
  # For PAM
  # environment.sessionVariables = {};

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
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8"; # en_US.UTF-8
    LC_TIME = "C.UTF-8";
    LC_COLLATE = "ru_RU.UTF-8"; # en_US.UTF-8
    LC_IDENTIFICATION = "ru_RU.UTF-8"; # en_US.UTF-8
  };

  fonts.packages = with pkgs; [
    cascadia-code
  ];
  fonts.fontconfig.defaultFonts.monospace = [
    "Cascadia Code NF"
  ];

  # харам, fhs
  services.envfs.enable = true;
  #? https://nix-community.github.io/NixOS-WSL/how-to/vscode.html
  # and other stuff
  programs.nix-ld.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    # extraGroups = [ "wheel" "networkmanager" "docker" ];
    # hashedPassword = "hashedPassword";
  };
  nix.settings.trusted-users = [ username ];

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;

  programs.nh = {
    enable = true;
    # TODO: 25.11
    package = pkgs.unstable.nh;
    clean.enable = true;
    clean.dates = "daily";
    clean.extraArgs = "--keep 5 --keep-since 4d";
    flake = flakePath;
  };
  imports = [
    inputs.home-manager.nixosModules.home-manager
    # ../modules/shell/fish.nix
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
