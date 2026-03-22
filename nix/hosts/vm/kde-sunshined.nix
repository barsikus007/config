{ username, ... }:
{
  imports = [
    ./minimal.nix
    ./sunshined.nix
    ../../hosts
    ../../modules/stylix.nix
    ../../modules/desktop/manager/plasma.nix
  ];
  home-manager.users.${username}.imports = [ ../../shared/zsh-compinit.nix ];
}
