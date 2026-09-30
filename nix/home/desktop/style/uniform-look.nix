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

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze";
  };

  gtk = {
    #! fuck you, gnome: https://stopthemingmy.app/
    enable = true;
    #! set by stylix to adw-gtk3 for no reason: https://github.com/nix-community/stylix/blob/e3861617645a43c9bbefde1aa6ac54dd0a44bfa9/modules/gtk/hm.nix#L59
    theme.package = lib.mkForce pkgs.kdePackages.breeze-gtk;
    theme.name = lib.mkForce (if config.stylix.polarity == "light" then "Breeze" else "Breeze-Dark");
    gtk4.theme = lib.mkForce null;
  };

  #? virt-viewer looks for plural "shortcuts" while breeze-icons names it singular "shortcut"
  xdg.dataFile = {
    "icons/breeze/preferences/22/preferences-desktop-keyboard-shortcuts-symbolic.svg".source =
      "${pkgs.kdePackages.breeze-icons}/share/icons/breeze/preferences/22/preferences-desktop-keyboard-shortcut-symbolic.svg";
    "icons/breeze-dark/preferences/22/preferences-desktop-keyboard-shortcuts-symbolic.svg".source =
      "${pkgs.kdePackages.breeze-icons}/share/icons/breeze-dark/preferences/22/preferences-desktop-keyboard-shortcut-symbolic.svg";
  };
}
