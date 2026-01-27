{ pkgs, self, ... }:
{
  home.packages = with pkgs; [
    self.packages.${pkgs.stdenv.hostPlatform.system}.bcompare5
    cifs-utils # to mount smb cause smb:// don't work
  ];
}
