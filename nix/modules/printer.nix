{ pkgs, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [ flakePackages.mprint ];
  };
}
