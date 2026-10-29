{ pkgs, ... }:
#? KDE apps, which are analog to useful Windows apps
{
  environment.systemPackages = with pkgs; [
    kdePackages.filelight
    kdePackages.kcalc
    kdePackages.kclock

    #? archiver and plugins
    kdePackages.ark
    arj
    unar

    kdePackages.elisa
    kdePackages.gwenview
    kdePackages.kimageformats
  ];
}
