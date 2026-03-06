{
  pkgs,
  inputs,
  username,
  flakePath,
  specialArgs,
  ...
}:
# TODO: refactor this file to make it contain reasonable minimal defaults (with no possible overhead) which can be used as base to **all** hosts
{
  environment.systemPackages =
    with pkgs;
    [
      home-manager
    ]
    ++ import ../shared/lists/00_essential.nix { inherit pkgs; }
    ++ import ../shared/lists/01_base.nix { inherit pkgs; };

  environment.variables = rec {
    EDITOR = "nvim";
    VISUAL = EDITOR;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.ksm.enable = true;

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

  fonts.packages = with pkgs; [
    cascadia-code
  ];
  fonts.fontconfig.defaultFonts.monospace = [
    "Cascadia Code NF"
  ];

  #? https://nix-community.github.io/NixOS-WSL/how-to/vscode.html
  # and other stuff
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 2222 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = specialArgs;
  home-manager.backupFileExtension = "hmbackup";
  #? fd -H hmbackup
  #? fd -H hmbackup | xargs rm

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    # extraGroups = [ "wheel" "networkmanager" "docker" ];
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
    clean.extraArgs = "--keep 5 --keep-since 7d";
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
