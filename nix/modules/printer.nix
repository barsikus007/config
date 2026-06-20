{ pkgs, self, ... }:
{
  services.printing = {
    enable = true;
    drivers = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.mprint
    ];
  };
}
