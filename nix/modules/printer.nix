{ pkgs, ... }:
{
  custom.persist.directories = [ "/var/lib/cups" ];

  services.printing = {
    enable = true;
    drivers = with pkgs; [ flakePackages.mprint ];
  };
}
