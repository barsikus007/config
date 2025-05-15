{ pkgs, ... }:
{
  home.packages = with pkgs; [
    #? fuck libreoffice, it still can't smooth scroll
    # libreoffice-qt
    # hunspell
    # hunspellDicts.ru_RU
    #! make fonts DeClArAtIvE https://wiki.nixos.org/wiki/ONLYOFFICE#Install_and_use_missing_corefonts
    onlyoffice-bin
  ];
}
