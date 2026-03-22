{ username, ... }:
#? opinionated, but I don't care for now
#! 2.2Gb
{
  imports = [
    ./minimal.nix
    ./paravirt-spiced.nix
    ../../hosts
    ../../modules/stylix.nix
    ../../modules/desktop/manager/niri.nix
  ];
  home-manager.users.${username}.imports = [ ../../shared/zsh-compinit.nix ];
}
