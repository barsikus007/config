{
  lib,
  pkgs,
  username,
  ...
}:
#! +1.1Gb
{
  imports = [
    ./niri.nix
    ../environment/explorer/dolphin.nix
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/quickshell/noctalia.nix ];

  programs.niri.useNautilus = false;

  environment.systemPackages = with pkgs; [
    kdePackages.qt6ct
    kdePackages.polkit-kde-agent-1
  ];
  services.gnome.gnome-keyring.enable = false;
  xdg.portal = {
    extraPortals = with pkgs; [
      kdePackages.kwallet
      kdePackages.xdg-desktop-portal-kde
    ];
    config.niri = {
      default = lib.mkForce [
        "kde"
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce "gnome";
      "org.freedesktop.impl.portal.FileChooser" = lib.mkForce "kde";
    };
  };
  #? Fix unpopulated MIME menus in dolphin: https://discourse.nixos.org/t/dolphin-does-not-have-mime-associations/48985/8
  environment.etc."/xdg/menus/applications.menu".text =
    builtins.readFile "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
}
