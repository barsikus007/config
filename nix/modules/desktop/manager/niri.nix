{
  lib,
  pkgs,
  config,
  inputs,
  username,
  ...
}:
#? https://wiki.nixos.org/wiki/Niri
let
  systemctl = lib.getExe' config.systemd.package "systemctl";
  dbus-update-activation-environment = lib.getExe' pkgs.dbus "dbus-update-activation-environment";
in
{
  #? https://github.com/epireyn/niri-flake/blob/2c9acaa7ebd5458f73e4977fff18cb3ea33d0471/flake.nix#L485
  nix.settings.extra-substituters = [ "https://niri-epireyn.cachix.org?priority=67" ];
  nix.settings.extra-trusted-public-keys = [
    "niri-epireyn.cachix.org-1:tlVyFN7CtsDT+ZcLPS+ekFWeT1X6X4OqvWqbBMyIzFA="
  ];
  nixpkgs.overlays = [
    (
      _final: prev:
      let
        niri-flake = inputs.niri.packages.${prev.stdenv.hostPlatform.system};
        niriPkg = niri-flake.niri-unstable;
      in
      {
        #? https://github.com/niri-wm/niri/pull/3572#issuecomment-5396691693
        niri = prev.symlinkJoin {
          inherit (niriPkg) name;
          paths = [ niriPkg ];
          postBuild = ''
            rm $out/bin/niri-session
            sed "s/systemctl --user import-environment/systemctl --user import-environment 2>\&1 | grep --line-buffered -v \"Calling import-environment without a list of variable names is deprecated.\"/" \
              ${niriPkg}/bin/niri-session > $out/bin/niri-session
            chmod +x $out/bin/niri-session
          '';
          passthru = niriPkg.passthru // {
            unwrapped = niriPkg;
          };
          meta = (niriPkg.meta or { }) // {
            mainProgram = "niri";
          };
        };
        xwayland-satellite = niri-flake.xwayland-satellite-unstable;
      }
    )
  ];

  imports = [
    ../.
  ];
  home-manager.users.${username}.imports = [ ../../../home/desktop/manager/niri.nix ];

  services.displayManager.defaultSession = "niri";
  services.displayManager.dms-greeter.compositor.name = "niri";
  services.greetd.settings.initial_session =
    lib.mkIf
      (
        config.services.displayManager.autoLogin.enable
        && config.services.displayManager.autoLogin.user != null
      )
      {
        command = "niri-session";
        user = config.services.displayManager.autoLogin.user;
      };

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
  #?   2. auto-themed Qt apps (KeePassXC) query the portal appearance/color-scheme at
  #?      startup before it is up, and silently fall back to light
  #? plain `After=` cannot fix (1): D-Bus activation bypasses ordering, so one oneshot
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
        ${systemctl} --user import-environment DISPLAY WAYLAND_DISPLAY
        ${dbus-update-activation-environment} --systemd DISPLAY WAYLAND_DISPLAY
        ${systemctl} --user restart xdg-desktop-portal-gnome.service
        ${systemctl} --user restart xdg-desktop-portal.service
      '';
    };
  };

  #? `WantedBy=` pulls autostart apps but doesn't order them; the generator gives them
  #? only `After=graphical-session.target`; add a per-unit drop-in ordering each one
  #? after portal-env-fix, so it sees a portal that is up and display-aware; list comes
  #? from home-manager `xdg.autostart.entries`, so new entries get the drop-in for free;
  #? uses `systemd.user.units` with raw text, not `systemd.user.services`: the latter
  #? auto-injects `[Service]` (PATH, Environment, ...) which under `asDropin` would
  #? override the real unit env; pattern matches `nixos/.../systemd/oomd.nix`
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
    #? xwininfo -root -tree | grep --invert-match '(has no name): ()'
    xwininfo
  ];

  #? perms for `niri-toggle-touchpad` and `capslock-layout-led` (both need group `input` write on sysfs)
  users.users.${username}.extraGroups = [ "input" ];
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="input", ATTR{name}=="*Touchpad*", RUN+="${lib.getExe' pkgs.coreutils "chgrp"} input /sys%p/inhibited", RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w /sys%p/inhibited"
    ACTION=="add|change", SUBSYSTEM=="leds", KERNEL=="*::capslock", RUN+="${lib.getExe' pkgs.coreutils "chgrp"} input /sys%p/brightness", RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w /sys%p/brightness"
  '';
}
