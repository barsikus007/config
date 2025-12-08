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

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
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
    LC_TIME = "C.UTF-8";
    LC_COLLATE = "en_US.UTF-8";
  };

  fonts.packages = with pkgs; [
    cascadia-code
  ];
  fonts.fontconfig.defaultFonts.monospace = [
    "Cascadia Code NF"
  ];

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
    openssh.authorizedKeys.keys = [
      (pkgs.lib.strings.removeSuffix "\n" (
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

  users.defaultUserShell = pkgs.zsh;
  programs.zsh.enable = true;
  programs.zsh.histSize = 100000;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.dates = "daily";
    clean.extraArgs = "--keep 5 --keep-since 4d";
    flake = flakePath;
  };
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../shared/nix.nix
    # ../modules/shell/fish.nix
  ];

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
