{ username, ... }:
#? opinionated, but I don't care for now
#! 2.2Gb
{
  imports = [
    ./paravirt-spiced.nix
    ../../hosts
    ../../modules/stylix.nix
    ../../modules/desktop/manager/niri.nix
  ];
  services.displayManager.gdm.enable = true;
  home-manager.users.${username}.imports = [ ../../shared/zsh-compinit.nix ];
}
