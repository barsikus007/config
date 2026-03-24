{ pkgs, ... }:
#? KDE apps, which are analog to useful Windows apps
{
  environment.systemPackages = with pkgs.kdePackages; [
    filelight
    kcalc
    kclock

    ark
    elisa
    gwenview
    kate
  ];
}
