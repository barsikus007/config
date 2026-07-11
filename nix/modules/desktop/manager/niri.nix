{
  lib,
  pkgs,
  config,
  inputs,
  username,
  ...
}:
#? https://wiki.nixos.org/wiki/Niri
{
  #? https://github.com/sodiboo/niri-flake/blob/c175f415488243723dc1a5514b286abbea6f93c1/flake.nix#L479
  nix.settings.extra-substituters = [ "https://niri.cachix.org" ];
  nix.settings.extra-trusted-public-keys = [
    "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
  ];
  nixpkgs.overlays = [
    (final: prev: {
      niri = inputs.niri.packages.${prev.stdenv.hostPlatform.system}.niri-unstable;
      # xwayland-satellite =
      #   inputs.niri.packages.${prev.stdenv.hostPlatform.system}.xwayland-satellite-unstable;
    })
  ];

  imports = [
    ../.
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/niri.nix ];

  services.displayManager.defaultSession = "niri";
  services.displayManager.dms-greeter.compositor.name = "niri";
  programs.niri.enable = true;

  #? cause it it set by module with no configuration, overriding the common settings
  xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = lib.mkIf (
    config.xdg.portal.config.common ? "org.freedesktop.impl.portal.FileChooser"
  ) (lib.mkForce config.xdg.portal.config.common."org.freedesktop.impl.portal.FileChooser");
  xdg.portal.config.niri."org.freedesktop.impl.portal.Secret" = lib.mkIf (
    config.xdg.portal.config.common ? "org.freedesktop.impl.portal.Secret"
  ) (lib.mkForce config.xdg.portal.config.common."org.freedesktop.impl.portal.Secret");

  #! vibecoded shitfix for autostart themes (envs) and tray icons
  #? two startup races bite niri here, both rooted in systemd-xdg-autostart-generator
  #? hardcoding `After=graphical-session.target` (man systemd-xdg-autostart-generator):
  #?   1. xdg-desktop-portal D-Bus-activates before niri/xwayland-satellite export
  #?      DISPLAY + WAYLAND_DISPLAY, so it spawns OpenURI/xdg-open apps (Firefox from a
  #?      clicked link) with an empty display => "no DISPLAY environment variable"
  #?   2. Auto-themed Qt apps (KeePassXC) query the portal appearance/color-scheme at
  #?      startup before it is up, and silently fall back to light
  #? plain `After=` cannot fix (1): D-Bus activation bypasses ordering. So one oneshot
  #? anchors the chain `xwayland-satellite -> portal-env-fix -> autostart apps`: it
  #? imports the env, then restarts the portal so it is up WITH a display before any Qt
  #? app asks for the theme. restart (not try-restart) also starts a not-yet-running
  #? portal, pre-warming it like Plasma core services do
  systemd.user.services.portal-env-fix = {
    description = "Import session env and (re)start xdg-desktop-portal with a display";
    wantedBy = [ "graphical-session.target" ];
    #! partOf lets it re-runs on every (re)login
    partOf = [ "graphical-session.target" ];
    before = [ "xdg-desktop-autostart.target" ];
    after = [
      "graphical-session.target"
      "xwayland-satellite.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "portal-env-fix" ''
        ${lib.getExe' pkgs.systemd "systemctl"} --user import-environment DISPLAY WAYLAND_DISPLAY
        ${lib.getExe' pkgs.dbus "dbus-update-activation-environment"} --systemd DISPLAY WAYLAND_DISPLAY
        ${lib.getExe' pkgs.systemd "systemctl"} --user restart xdg-desktop-portal.service
      '';
    };
  };

  #? `WantedBy=` pulls autostart apps but doesn't order them; the generator gives them
  #? only `After=graphical-session.target`. Add a per-unit drop-in ordering each one
  #? after portal-env-fix, so it sees a portal that is up and display-aware. List comes
  #? from home-manager `xdg.autostart.entries`, so new entries get the drop-in for free.
  #? Uses `systemd.user.units` with raw text, not `systemd.user.services`: the latter
  #? auto-injects `[Service]` (PATH, Environment, ...) which under `asDropin` would
  #? override the real unit env. Pattern matches `nixos/.../systemd/oomd.nix`
  systemd.user.units = lib.listToAttrs (
    map (
      entry:
      let
        #? strip store-path context from `baseNameOf` so it can be used as
        #? an attribute name (Nix rejects "string refers to a store path")
        desktop = builtins.unsafeDiscardStringContext (baseNameOf entry);
        #? generator naming: `app-<basename-without-.desktop>@autostart.service`
        instance = "app-${lib.removeSuffix ".desktop" desktop}@autostart.service";
      in
      {
        name = instance;
        value = {
          overrideStrategy = "asDropin";
          text = /* ini */ ''
            [Unit]
            After=portal-env-fix.service
            Wants=portal-env-fix.service
          '';
        };
      }
    ) config.home-manager.users.${username}.xdg.autostart.entries
  );

  environment.sessionVariables = {
    #? fix messed fonts in java GUI apps
    #? for <=jdk8 _JAVA_OPTIONS
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
    JDK_JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true";
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    #? xwininfo -root -tree | grep -v '(has no name): ()'
    xwininfo
  ];

  #? perms for `niri-toggle-touchpad` and `capslock-layout-led` (both need group `input` write on sysfs)
  users.users.${username}.extraGroups = [ "input" ];
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="input", ATTR{name}=="*Touchpad*", RUN+="${lib.getExe' pkgs.coreutils "chgrp"} input /sys%p/inhibited", RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w /sys%p/inhibited"
    ACTION=="add|change", SUBSYSTEM=="leds", KERNEL=="*::capslock", RUN+="${lib.getExe' pkgs.coreutils "chgrp"} input /sys%p/brightness", RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w /sys%p/brightness"
  '';
}
