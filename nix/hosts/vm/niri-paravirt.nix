#? opinionated, but I don't care for now
#! 2.2Gb
{
  imports = [
    ./.
    ./paravirt-spiced.nix
    ../../modules/stylix.nix
    ../../modules/desktop/manager/niri.nix
  ];
}
