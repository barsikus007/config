{ pkgs, self, ... }:
{
  custom.persist.home.directories = [ ".config/bcompare5" ];

  home.packages = with pkgs; [
    self.packages.${pkgs.stdenv.hostPlatform.system}.bcompare
    cifs-utils # to mount smb cause smb:// don't work
  ];
}
