{ pkgs, ... }:
{
  custom.persist.home.directories = [ ".config/bcompare5" ];

  home.packages = with pkgs; [
    flakePackages.bcompare
    cifs-utils # to mount smb cause smb:// don't work
  ];
}
