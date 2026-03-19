{ lib, pkgs, ... }:
#? https://wiki.nixos.org/wiki/Dolphin
{
  xdg.portal.extraPortals = with pkgs; [ kdePackages.xdg-desktop-portal-kde ];
  xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "kde" ];

  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.qtsvg
    kdePackages.kio
    kdePackages.kio-fuse
    kdePackages.kio-extras

    #? have issues with focus, it should focus to explorer every time
    # alias explorer.exe='kioclient exec'
    (writeShellScriptBin "explorer.exe" ''
      dolphin --new-window "$@" 1>/dev/null 2>/dev/null & disown
    '')
  ];
}
