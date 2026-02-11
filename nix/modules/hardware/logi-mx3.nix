{
  lib,
  pkgs,
  config,
  ...
}:
#? https://github.com/NixOS/nixpkgs/pull/287399
let
  cfg.package = pkgs.logiops_0_2_3;
in
{
  systemd.services.logiops = {
    description = "Logitech Configuration Daemon";
    documentation = [ "https://github.com/PixlOne/logiops" ];

    wantedBy = [ "multi-user.target" ];

    startLimitIntervalSec = 0;
    after = [ "multi-user.target" ];
    wants = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${lib.getExe cfg.package}";
      Restart = "always";
      User = "root";

      RuntimeDirectory = "logiops";

      CapabilityBoundingSet = [ "CAP_SYS_NICE" ];
      DeviceAllow = [
        "/dev/uinput rw"
        "char-hidraw rw"
      ];
      ProtectClock = true;
      PrivateNetwork = true;
      ProtectHome = true;
      ProtectHostname = true;
      PrivateUsers = true;
      PrivateMounts = true;
      PrivateTmp = true;
      RestrictNamespaces = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      LockPersonality = true;
      ProtectProc = "invisible";
      SystemCallFilter = [
        "nice"
        "@system-service"
        "~@privileged"
      ];
      RestrictAddressFamilies = [
        "AF_NETLINK"
        "AF_UNIX"
      ];
      RestrictSUIDSGID = true;
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ProcSubset = "pid";
      UMask = "0077";
    };
  };

  # Add a `udev` rule to restart `logiops` when the mouse is connected
  # https://github.com/PixlOne/logiops/issues/239#issuecomment-1044122412
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", ATTRS{id/vendor}=="046d", RUN{program}="${config.systemd.package}/bin/systemctl --no-block try-restart logiops.service"
  '';

  #? https://wiki.archlinux.org/title/Logitech_MX_Master#Logiops
  environment.etc."logid.cfg".text = ''
    devices: ({
      name: "Wireless Mouse MX Master 3";
      smartshift: {
        on: true;
        threshold: 12;
      };
      hiresscroll: {
        hires: true;
      };
      buttons: ({
        cid: 0xc3;
        action = {
          type: "Gestures";
          gestures: ({
            direction: "Left";
            mode: "OnRelease";
            action = {
              type = "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_LEFTCTRL", "KEY_LEFT"];
            };
          }, {
            direction: "Right";
            mode: "OnRelease";
            action = {
              type = "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_LEFTCTRL", "KEY_RIGHT"];
            };
          }, {
            direction: "Down";
            mode: "OnRelease";
            action = {
              type: "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_LEFTCTRL", "KEY_DOWN"];
            };
          }, {
            direction: "Up";
            mode: "OnRelease";
            action = {
              type: "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_LEFTCTRL", "KEY_UP"];
            };
          }, {
            direction: "None";
            mode: "OnRelease";
            action = {
              type = "Keypress";
              keys: ["KEY_LEFTMETA", "KEY_TAB"];
            };
          });
        };
      });
    });
  '';
}
