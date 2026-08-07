{
  lib,
  pkgs,
  config,
  ...
}:
#? https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
{
  #! hicolor/index.theme ships only in the system profile, so icon resolvers skip the
  #! user-profile hicolor entirely and app icons from home.packages never resolve
  #? symptom: ayugram tray icon (com.ayugram.desktop-attention-symbolic) falls back to a placeholder
  home.packages = with pkgs; [ hicolor-icon-theme ];

  #? stylix uses kvantum for theming, hardcoding svg (which is used for element shapes)
  #? I don't like these shapes so I decided to just rollback to breeze
  qt = {
    enable = true;
    platformTheme.name = lib.mkForce "kde";
    style = {
      name = lib.mkForce "breeze";
      package = lib.mkForce pkgs.kdePackages.breeze;
    };
  };

  gtk = {
    #? some icons are missing with breeze-icons in gtk2
    gtk2.iconTheme.package = pkgs.gnome-icon-theme;
    gtk2.iconTheme.name = "gnome";
    #! set by stylix to adw-gtk3 for no reason: https://github.com/nix-community/stylix/blob/e3861617645a43c9bbefde1aa6ac54dd0a44bfa9/modules/gtk/hm.nix#L59
    theme.package = lib.mkForce pkgs.kdePackages.breeze-gtk;
    theme.name = lib.mkForce (if (config.stylix.polarity == "light") then "Breeze" else "Breeze-Dark");
    #? gtk.gtk4.theme: https://nix-community.github.io/home-manager/release-notes.xhtml#sec-release-26.05-state-version-changes
    #! https://github.com/nix-community/home-manager/blob/d401492e2acd4fea42f7705a3c266cea739c9c36/modules/misc/gtk/gtk4.nix#L69
  };
}
