{ lib, pkgs, ... }:
#? https://wiki.nixos.org/wiki/Niri
{
  imports = [
    ../default.nix
  ];

  services.displayManager.defaultSession = "niri";
  programs.niri = {
    enable = true;
    useNautilus = false;
  };
  #? configure for KDE things
  environment.systemPackages = with pkgs; [
    xwayland-satellite
    kdePackages.qt6ct
    kdePackages.polkit-kde-agent-1
  ];
  services.gnome.gnome-keyring.enable = false;
  xdg.portal = {
    extraPortals = with pkgs; [
      kdePackages.kwallet
      kdePackages.xdg-desktop-portal-kde
    ];
    # wlr = { };
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

  programs.dms-shell = {
    # enable = true;
    systemd.enable = false;
  };
}
