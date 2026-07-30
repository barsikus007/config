{ pkgs, self, ... }:
{
  custom.persist.directories = [ "/var/lib/cups" ];

  services.printing = {
    enable = true;
    drivers = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.mprint
    ];
  };
}
