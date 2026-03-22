{ pkgs, ... }:
#? KDE apps, which are analog to useful Windows apps
{
  environment.systemPackages = with pkgs.kdePackages; [
    filelight
    kcalc
    kclock

    elisa
    gwenview
    kate
  ];
}
