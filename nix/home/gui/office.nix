{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #? fuck libreoffice, it still can't smooth scroll
    libreoffice-qt6-fresh
    # spellchecks defined at system level

    #? fuck onlyoffice, it is very slow and laggy (but nice and smooth)
    # onlyoffice-bin
    #! make fonts DeClArAtIvE https://wiki.nixos.org/wiki/ONLYOFFICE#Install_and_use_missing_corefonts
  ];
}
