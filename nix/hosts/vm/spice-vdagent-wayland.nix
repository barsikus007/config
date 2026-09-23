{ lib, pkgs, ... }:
let
  spice-vdagent-wayland = pkgs.spice-vdagent.overrideAttrs (previousAttrs: {
    version = "0.23.0-unstable-2026-09-14";
    #! https://gitlab.freedesktop.org/spice/linux/vd_agent/-/merge_requests/57
    src = pkgs.fetchFromGitLab {
      domain = "gitlab.freedesktop.org";
      owner = "v-dermichev";
      repo = "vd_agent";
      rev = "f25c7927cae05ae9cf9838a70bb20b2fb09e6122";
      hash = "sha256-fYVCSO8X9GQRilHniGPB9pxkMMsqalKNYhT7PeOJYTg=";
    };
    nativeBuildInputs =
      (previousAttrs.nativeBuildInputs or [ ])
      ++ (with pkgs; [
        autoreconfHook
        wayland-scanner
      ]);
    buildInputs =
      (previousAttrs.buildInputs or [ ])
      ++ (with pkgs; [
        wayland
        wayland-protocols
      ]);
    configureFlags = (previousAttrs.configureFlags or [ ]) ++ [
      "--with-wayland=yes"
    ];
    #? upstream gcc16 commit e3c74bd is already in this branch
    patches = [
      (pkgs.writeText "niri-resize.patch" ''
        --- a/src/vdagent/wayland/display.c
        +++ b/src/vdagent/wayland/display.c
        @@ -150,6 +150,19 @@ void vdagent_wayland_set_monitor_config(VDAgentWayland *w,
                 g_free(mode);
                 if (ok)
                     return;
             }
        +    if (g_getenv("NIRI_SOCKET") != NULL) {
        +        gchar *mode = g_strdup_printf("%ux%u@60", width, height);
        +        gchar *script = g_strdup_printf(
        +            "out=$(niri msg --json outputs 2>/dev/null | jq -r 'keys[0] // empty'); "
        +            "[ -n \"$out\" ] && niri msg output \"$out\" custom-mode \"%s\"",
        +            mode);
        +        gchar *argv[] = { "sh", "-c", script, NULL };
        +        gboolean ok = spawn_compositor_cmd("sh", argv);
        +        g_free(script);
        +        g_free(mode);
        +        if (ok)
        +            return;
        +    }
             syslog(LOG_DEBUG, "wayland: MONITORS_CONFIG %ux%u — no supported compositor backend",
                    width, height);
         }
      '')
    ];
  });
in
{
  services.spice-vdagentd.enable = true;

  systemd.services.spice-vdagentd.serviceConfig.ExecStart =
    lib.mkForce "${spice-vdagent-wayland}/bin/spice-vdagentd";

  #? session agent running inside graphical user session for Wayland clipboard sync
  #! https://github.com/nixos/nixpkgs/issues/481078
  systemd.user.services.spice-vdagent = {
    description = "spice guest session agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    unitConfig.ConditionPathExists = "/run/spice-vdagentd/spice-vdagent-sock";
    path = with pkgs; [
      bash
      jq
      niri
    ];
    serviceConfig = {
      ExecStart = "${spice-vdagent-wayland}/bin/spice-vdagent --foreground";
      StandardError = "journal";
    };
  };
}
