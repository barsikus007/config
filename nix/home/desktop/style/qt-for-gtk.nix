{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.sessionVariables.GTK2_RC_FILES = config.gtk.gtk2.configLocation;
  gtk = {
    gtk2 = {
      configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
      iconTheme.package = with pkgs; gnome-icon-theme;
      iconTheme.name = "gnome";
    };
    iconTheme.package = with pkgs; kdePackages.breeze-icons;
    iconTheme.name = lib.mkForce (
      if (config.stylix.polarity == "light") then "breeze" else "breeze-dark"
    );
    theme.package = lib.mkForce (with pkgs; kdePackages.breeze-gtk);
    theme.name = lib.mkForce (if (config.stylix.polarity == "light") then "Breeze" else "Breeze-Dark");
    #? https://nix-community.github.io/home-manager/release-notes.xhtml#sec-release-26.05-state-version-changes
  };
}
