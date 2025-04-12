{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # initial
    git
    curl
    wget

    # base
    mc
    bat
    duf
    gdu
    fzf
    btop
    neovim
    zoxide
    ripgrep
    # add
    eza
    tmux
    tree
    # fastfetch
    zsh
    fish
    lazydocker

    # nix
    nixfmt-rfc-style
    nixd
    nil
    home-manager
    nix-diff
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  

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
}
