{ pkgs, ... }:
#? KDE apps, which are analog to useful Windows apps
{
  environment.systemPackages = with pkgs; [
    kdePackages.filelight
    kdePackages.kclock
    kdePackages.kcalc
  ];
}
