{
  custom.persist.home.directories = [ ".config/libreoffice" ];

  #? fuck libreoffice, it still can't smooth scroll
  programs.libreoffice.enable = true;
  # spellchecks defined at system level

  #? fuck onlyoffice, it is very slow and laggy (but nice and smooth)
  # programs.onlyoffice.enable = true;
  #! make fonts DeClArAtIvE https://wiki.nixos.org/wiki/ONLYOFFICE#Install_and_use_missing_corefonts
}
