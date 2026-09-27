{
  lib,
  config,
  username,
  ...
}:
{
  custom.persist = {
    directories =
      lib.optional config.networking.networkmanager.enable "/etc/NetworkManager/system-connections"
      ++ lib.optional config.services.openssh.enable "/etc/ssh"
      ++ lib.optional config.hardware.bluetooth.enable "/var/lib/bluetooth"
      ++ lib.optional (
        config.security.sudo.enable || config.security.sudo-rs.enable
      ) "/var/db/sudo/lectured"
      ++ lib.optional config.services.asusd.enable "/etc/asusd" # ? current anime state
      ++ lib.optional config.services.power-profiles-daemon.enable "/var/lib/power-profiles-daemon" # ? selected power-profile
      ++ lib.optional config.services.upower.enable "/var/lib/upower" # ? history of power usage
      ++ lib.optional config.services.printing.enable "/var/lib/cups"
      ++ lib.optional config.virtualisation.libvirtd.enable "/var/lib/libvirt"
      ++ lib.optional config.services.fprintd.enable "/var/lib/fprint" # ? enrolled fingerprints
      ++ lib.optional config.virtualisation.waydroid.enable "/var/lib/waydroid"
      ++ lib.optional config.services.displayManager.noctalia-greeter.enable {
        # ? greeter sync with shell
        directory = "/var/lib/noctalia-greeter";
        user = "greeter";
        group = "greeter";
      };

    home.directories =
      lib.optionals config.virtualisation.waydroid.enable [
        ".config/waydroid-helper" # ? key mappings
        ".config/systemd/user/waydroid-monitor.service.d" # ? links to storage
      ]
      ++ lib.optional config.programs.throne.enable ".config/Throne"
      ++ lib.optional config.programs.dsearch.enable ".cache/danksearch"
      ++ lib.optional config.programs.kdeconnect.enable ".config/kdeconnect"
      ++ lib.optional config.programs.obs-studio.enable ".config/obs-studio"
      ++ lib.optional config.programs.gpu-screen-recorder.enable ".config/gpu-screen-recorder"
      ++ lib.optional config.programs.steam.enable ".steam"
      ++ lib.optionals config.services.sunshine.enable [
        ".config/sunshine" # ? auth
        ".config/Moonlight Game Streaming Project"
      ]
      ++ lib.optional config.services.rustdesk-server.enable ".config/rustdesk"
      ++ lib.optional (builtins.elem "adbusers" (
        config.users.users.${username}.extraGroups or [ ]
      )) ".android"
      ++ lib.optional (config ? sops && config.sops.secrets != { }) ".config/sops/age";
  };
}
