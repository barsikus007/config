{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  systemctl = lib.getExe' pkgs.systemd "systemctl";
  gdbus = lib.getExe' pkgs.glib "gdbus";
  gsettings = lib.getExe' pkgs.glib "gsettings";

  cfg = osConfig.stylix-activationless or null;
  userDarkFarm = cfg.farms.userDark;
  userLightFarm = cfg.farms.userLight;
  darkWallpaper = osConfig.stylix.image;
  lightWallpaper = cfg.light.image;
  darkPlasma = cfg.scripts.darkPlasma or null;
  lightPlasma = cfg.scripts.lightPlasma or null;

  stylixSwitch = pkgs.writeShellScriptBin "stylix-switch" ''
    set -euo pipefail

    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    userEnv=$(${systemctl} --user show-environment 2>/dev/null || true)
    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      WAYLAND_DISPLAY=$(sed -En 's/^WAYLAND_DISPLAY=(.*)/\1/p' <<< "$userEnv")
      export WAYLAND_DISPLAY
    fi
    if [ -z "''${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
      DBUS_SESSION_BUS_ADDRESS=$(sed -En 's/^DBUS_SESSION_BUS_ADDRESS=(.*)/\1/p' <<< "$userEnv")
      export DBUS_SESSION_BUS_ADDRESS
    fi
    export XDG_DATA_DIRS="/run/current-system/sw/share:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:''${XDG_DATA_DIRS:-}"

    mode="''${1:-}"
    stateDir="$HOME/.local/state/stylix"
    mkdir --parents "$stateDir"

    case "$mode" in
      (light)
        farm="${userLightFarm}"
        wallpaper="${lightWallpaper}"
        colorScheme="prefer-light"
        gtkTheme="Breeze"
        iconTheme="breeze"
        plasmaScript="${lightPlasma}"
        noctaliaMode="light"
        ;;
      (dark)
        farm="${userDarkFarm}"
        wallpaper="${darkWallpaper}"
        colorScheme="prefer-dark"
        gtkTheme="Breeze-Dark"
        iconTheme="breeze-dark"
        plasmaScript="${darkPlasma}"
        noctaliaMode="dark"
        ;;
      (*)
        echo "usage: stylix-switch [dark|light]" >&2
        exit 1
        ;;
    esac

    ln --symbolic --force --no-dereference "$farm" "$stateDir/current"
    ln --symbolic --force --no-dereference "$wallpaper" "$stateDir/current-wallpaper"
    ${gsettings} set org.gnome.desktop.interface color-scheme "$colorScheme" || true
    ${gsettings} set org.gnome.desktop.interface gtk-theme "$gtkTheme" || true
    ${gsettings} set org.gnome.desktop.interface icon-theme "$iconTheme" || true
    #! xdg-desktop-portal-gnome caches color-scheme at its process start
    #! restarting it alone clears ScreenCast properties on xdg-desktop-portal
    ${systemctl} --user restart xdg-desktop-portal-gnome.service || true
    ${systemctl} --user restart xdg-desktop-portal.service || true
    if [ -n "$plasmaScript" ]; then
      "$plasmaScript" || true
    fi

    #! at boot the activation runs as a system unit with no session bus, gdbus exits 1 and aborts the rest of the DAG
    if [ -n "''${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
      #! Kirigami/KF6 apps need kconfig.notify.ConfigChanged to reparse kdeglobals before notifyChange
      ${gdbus} emit --session --object-path /kdeglobals --signal org.kde.kconfig.notify.ConfigChanged "{'General': [b'ColorScheme'], 'Colors:Window': [b'BackgroundNormal'], 'Colors:View': [b'BackgroundNormal'], 'Colors:Button': [b'BackgroundNormal'], 'Colors:Selection': [b'BackgroundNormal']}" || true
      ${gdbus} emit --session --object-path /KGlobalSettings --signal org.kde.KGlobalSettings.notifyChange 0 0 || true
    fi
    if command -v noctalia >/dev/null 2>&1; then
      noctalia msg wallpaper-set "$wallpaper" || true
      noctalia msg theme-mode-set "$noctaliaMode" || true
    fi
    if command -v vicinae >/dev/null 2>&1; then
      vicinae theme set stylix || true
    fi
    pkill -SIGUSR2 btop 2>/dev/null || true
  '';
in
{
  home.packages = [ stylixSwitch ];

  #! QT-based apps: https://github.com/telegramdesktop/tdesktop/issues/26370
  #! Dolphin drops its view-props xattr on this reload, so it binds to dolphinViewProperties
  home.activation.applyStylixTheme =
    lib.hm.dag.entryBetween [ "dolphinViewProperties" ] [ "dconfSettings" ]
      /* shell */ ''
        mode=$(${lib.getExe pkgs.darkman} get 2>/dev/null || readlink "$HOME/.local/state/stylix/current" 2>/dev/null || echo "dark")
        run ${stylixSwitch}/bin/stylix-switch "$mode"
      '';

  services.darkman = {
    enable = true;
    darkModeScripts = {
      switch-to-dark = "${stylixSwitch}/bin/stylix-switch dark";
    };
    lightModeScripts = {
      switch-to-light = "${stylixSwitch}/bin/stylix-switch light";
    };
    settings = {
      lat = 42;
      lng = 40;
      # usegeoclue = true;
    };
  };
}
